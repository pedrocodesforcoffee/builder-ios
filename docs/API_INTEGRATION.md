# API Integration Documentation

## Authentication Flow

### Auth Manager
The `AuthManager` is the central service for all authentication operations.

#### Key Features
1. **Centralized State Management**
   - Single source of truth for authentication state
   - Published properties for UI binding
   - State transitions: unknown → authenticated/unauthenticated → refreshing

2. **Automatic Token Refresh**
   - Proactive refresh before expiry (5 minutes before)
   - Reactive refresh on 401 responses
   - Retry logic with exponential backoff
   - Maximum 3 refresh attempts before logout

3. **Session Management**
   - App lifecycle monitoring
   - Background refresh when app returns to foreground
   - Automatic logout on session expiry

### Token Lifecycle

```
Login → Store Tokens → Schedule Refresh
           ↓
    API Request → Include Bearer Token
           ↓
    401 Response → Refresh Token → Retry Request
           ↓
    Refresh Fails → Logout
```

### API Request Flow

1. **Request Initiated**
   - APIClient adds Bearer token from TokenManager
   - Request sent to server

2. **Success Response (200-299)**
   - Data returned to caller
   - No additional auth handling needed

3. **Unauthorized Response (401)**
   - Notification posted to AuthManager
   - AuthManager attempts token refresh
   - Original request retried with new token
   - If refresh fails, user logged out

4. **Other Errors**
   - Standard error handling
   - Retry logic for network errors

### Protected Endpoints

All endpoints except `/auth/*` require authentication:

```swift
// Automatically includes Bearer token
let request = GetProjectsRequest()
let response = try await apiClient.execute(request)
```

### Error Handling

| Error | Handling | User Experience |
|-------|----------|-----------------|
| Invalid Credentials | Show error message | Remain on login screen |
| Token Expired | Auto-refresh | Seamless continuation |
| Refresh Failed | Force logout | Return to login |
| Network Error | Retry with backoff | Show retry option |
| Server Error | Log and display | Error message |

## Auth Manager Implementation

### States

```swift
enum AuthState {
    case unknown        // Initial state
    case authenticated  // User logged in
    case unauthenticated // User logged out
    case refreshing     // Token refresh in progress
}
```

### Methods

#### Authentication
- `login(email:password:)` - Authenticate user with credentials
- `logout()` - Sign out user and clear tokens
- `register(email:password:firstName:lastName:)` - Create new account
- `loginWithBiometric(context:)` - Authenticate with Face ID/Touch ID

#### Token Management
- `refreshTokens()` - Manually refresh access token
- `checkAndRefreshIfNeeded()` - Check expiry and refresh if needed
- `scheduleTokenRefresh(expiresIn:)` - Schedule automatic refresh

#### State
- `isAuthenticated: Bool` - Current authentication status
- `currentUser: User?` - Currently logged in user
- `authState: AuthState` - Current authentication state

## Integration Guide

### Using AuthManager in Views

```swift
@MainActor
class MyViewModel: ObservableObject {
    private let authManager = AuthManager.shared

    init() {
        // Subscribe to auth state
        authManager.$isAuthenticated
            .sink { [weak self] isAuthenticated in
                // Handle authentication changes
            }
            .store(in: &cancellables)
    }

    func performAuthenticatedAction() async {
        guard authManager.isAuthenticated else {
            // Handle unauthenticated state
            return
        }

        // Perform action - token will be added automatically
    }
}
```

### Making Authenticated API Calls

```swift
// 1. Create request (token added automatically)
let request = GetProjectsRequest(page: 1, limit: 20)

// 2. Execute request
do {
    let response = try await apiClient.execute(request)
    // Handle response
} catch {
    // Handle error (401 will auto-refresh and retry)
}
```

### Handling Token Refresh

Token refresh is automatic, but you can listen for events:

```swift
// Listen for token refresh notification
NotificationCenter.default.publisher(for: .tokenRefreshed)
    .sink { _ in
        // Token was refreshed, retry failed requests
    }
    .store(in: &cancellables)
```

## Security Considerations

1. **Token Storage**
   - Access tokens: Keychain (no biometric)
   - Refresh tokens: Keychain (optional biometric)
   - Never in memory longer than needed

2. **Token Transmission**
   - HTTPS only in production
   - Bearer token in Authorization header
   - No tokens in URL parameters

3. **Session Security**
   - Tokens expire after inactivity
   - Device-specific tokens
   - Logout clears all tokens

## Testing Authentication

### Manual Testing Checklist

1. **Login Flow**
   - [ ] Valid credentials login succeeds
   - [ ] Invalid credentials show error
   - [ ] Network error handled gracefully
   - [ ] Tokens stored in Keychain

2. **Token Refresh**
   - [ ] Proactive refresh before expiry
   - [ ] 401 triggers refresh and retry
   - [ ] Failed refresh logs out user
   - [ ] Multiple simultaneous requests handled

3. **Logout Flow**
   - [ ] Tokens cleared from Keychain
   - [ ] User redirected to login
   - [ ] Server notified of logout
   - [ ] Navigation state reset

4. **App Lifecycle**
   - [ ] Tokens persist across app restarts
   - [ ] Background app refreshes token on foreground
   - [ ] Expired tokens handled on app open

### Testing Token Expiry

```swift
// In development, set short token expiry
// Backend: expiresIn: 60 // 1 minute

// 1. Login successfully
// 2. Wait 45 seconds
// 3. Make API call
// Expected: Token refreshes proactively

// 4. Wait another 30 seconds (token expired)
// 5. Make API call
// Expected: 401 triggers refresh, request retries
```

## Best Practices

1. **Always use AuthManager for auth operations**
   - Don't call auth APIs directly
   - Don't manage tokens manually
   - Use centralized state

2. **Handle auth state changes**
   - Subscribe to `$isAuthenticated`
   - Update UI based on state
   - Clear sensitive data on logout

3. **Test token refresh thoroughly**
   - Simulate token expiry
   - Test 401 handling
   - Verify retry logic

4. **Monitor auth state**
   - Log auth state transitions
   - Track refresh attempts
   - Alert on repeated failures

5. **Secure credential storage**
   - Use Keychain for all tokens
   - Enable biometric for sensitive data
   - Clear tokens on logout

## API Endpoints

### Authentication Endpoints

#### POST /auth/login
Login with email and password

**Request:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "accessToken": "eyJhbGci...",
  "refreshToken": "eyJhbGci...",
  "tokenType": "Bearer",
  "expiresIn": 3600,
  "user": {
    "id": "123",
    "email": "user@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "role": "user"
  }
}
```

#### POST /auth/register
Create new user account

**Request:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "firstName": "John",
  "lastName": "Doe"
}
```

**Response:** Same as login

#### POST /auth/refresh
Refresh access token

**Request:**
```json
{
  "refreshToken": "eyJhbGci..."
}
```

**Response:**
```json
{
  "accessToken": "eyJhbGci...",
  "refreshToken": "eyJhbGci...",
  "tokenType": "Bearer",
  "expiresIn": 3600
}
```

#### POST /auth/logout
Logout current user

**Request:** None (uses Bearer token)

**Response:** 204 No Content

### Protected Endpoints

#### GET /projects
Get list of projects (requires authentication)

**Query Parameters:**
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 20)

**Response:**
```json
{
  "projects": [...],
  "total": 100,
  "page": 1,
  "totalPages": 5
}
```

#### GET /projects/:id
Get project details (requires authentication)

**Response:**
```json
{
  "id": "123",
  "name": "Project Name",
  "status": "Active",
  "progress": 0.65,
  "dueDate": "2025-12-31T00:00:00Z",
  "location": "123 Main St",
  "description": "Project description"
}
```

## Troubleshooting

### Token Refresh Fails
**Symptom:** User logged out unexpectedly

**Possible Causes:**
1. Refresh token expired
2. Network connectivity issues
3. Server-side token invalidation

**Solutions:**
- Check token expiry settings
- Verify network connectivity
- Check server logs

### 401 Loop
**Symptom:** Repeated 401 responses

**Possible Causes:**
1. Token refresh not working
2. Invalid refresh token
3. Server not recognizing token

**Solutions:**
- Check AuthManager logs
- Verify token storage
- Clear Keychain and re-login

### Missing Authorization Header
**Symptom:** All API calls return 401

**Possible Causes:**
1. TokenManager not returning token
2. Token not in Keychain
3. APIClient not adding header

**Solutions:**
- Check TokenManager.getAccessToken()
- Verify Keychain storage
- Check APIClient.buildURLRequest()

## Monitoring and Debugging

### Enable Auth Logging

All auth operations are logged with prefixes:
- 🔐 Login attempts
- 🔄 Token refresh
- ⚠️ Auth warnings
- ❌ Auth errors
- ✅ Auth success

### Check Auth State

```swift
// In Xcode debugger
po AuthManager.shared.authState
po AuthManager.shared.isAuthenticated
po TokenManager.shared.getAccessToken()
```

### Monitor Notifications

```swift
// Add observers for debugging
NotificationCenter.default.addObserver(forName: .tokenExpired, object: nil, queue: .main) { _ in
    print("🔔 Token expired notification")
}

NotificationCenter.default.addObserver(forName: .unauthorizedResponse, object: nil, queue: .main) { _ in
    print("🔔 Unauthorized response notification")
}

NotificationCenter.default.addObserver(forName: .tokenRefreshed, object: nil, queue: .main) { _ in
    print("🔔 Token refreshed notification")
}
```

---

**Task 3.2.2.3.I Complete**: Auth Manager with automatic token refresh implemented successfully! 🎉
