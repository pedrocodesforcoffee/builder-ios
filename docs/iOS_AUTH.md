# iOS Authentication Documentation

## Overview
The iOS app uses JWT-based authentication with the backend API to secure user access and maintain session state.

## Architecture Components

### 1. Authentication Models (`Core/Models/AuthModels.swift`)
- **LoginRequest**: Email and password credentials
- **LoginResponse**: Contains user data and authentication tokens
- **User**: User profile information (id, email, firstName, lastName, role)
- **AuthTokens**: Access token, refresh token, and expiration time
- **RegisterRequest**: Registration data structure (for future use)
- **APIErrorResponse**: Standardized error response format

### 2. API Requests (`Core/Networking/Requests/AuthRequests.swift`)
- **LoginAPIRequest**: POST `/auth/login` - Authenticate user
- **RefreshTokenAPIRequest**: POST `/auth/refresh` - Refresh access token
- **LogoutAPIRequest**: POST `/auth/logout` - Sign out user
- **EmptyResponse**: Generic empty response for logout

### 3. Login View Model (`Features/Authentication/LoginView.swift`)
- **Real-time validation**: Email format and password length
- **Debounced input**: 500ms delay before validation
- **State management**: Using `ViewState<Bool>` pattern
- **Error handling**: Comprehensive error mapping for user-friendly messages
- **API integration**: Direct integration with APIClient

### 4. Login View (`Features/Authentication/LoginView.swift`)
- **Enhanced UI**: Gradient background, error states, password visibility toggle
- **Keyboard management**: Focus states and submit handlers
- **Biometric preparation**: Face ID/Touch ID UI elements (implementation in next task)
- **Loading overlay**: Prevents multiple submissions
- **Responsive validation**: Real-time error display

## Authentication Flow

### 1. User Login
```
User enters credentials
    ↓
Client-side validation (email format, password length)
    ↓
POST /api/auth/login with credentials
    ↓
Backend validates and returns tokens
    ↓
Store tokens (currently UserDefaults, moving to Keychain in Task 3.2.2.2.I)
    ↓
Update AppCoordinator.isAuthenticated = true
    ↓
Navigate to main app (MainTabView)
```

### 2. Request Authentication (Future - Task 3.2.2.3.I)
```
API request initiated
    ↓
APIClient intercepts request
    ↓
Inject Authorization: Bearer {access_token} header
    ↓
Send request to backend
    ↓
If 401 Unauthorized → Attempt token refresh
    ↓
If refresh succeeds → Retry original request
    ↓
If refresh fails → Logout and redirect to login
```

## Form Validation

### Email Validation
- **Pattern**: `[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}`
- **Triggers**: Debounced after 500ms of inactivity
- **Error Message**: "Please enter a valid email address"
- **Empty State**: No error shown for empty field

### Password Validation
- **Minimum Length**: 6 characters
- **Triggers**: Debounced after 500ms of inactivity
- **Error Message**: "Password must be at least 6 characters"
- **Empty State**: No error shown for empty field

### Login Button State
Enabled only when:
- ✅ Email is not empty
- ✅ Password is not empty
- ✅ No email validation error
- ✅ No password validation error
- ✅ Not currently loading

## Error Handling

### Error Types and Messages
| Error Type | User Message |
|-----------|-------------|
| `unauthorized` (401) | "Invalid email or password. Please try again." |
| `noInternetConnection` | "No internet connection. Please check your network and try again." |
| `timeout` | "Request timed out. Please try again." |
| `httpError(400)` | "Invalid credentials. Please check your email and password." |
| `httpError(5xx)` | "Server error (XXX). Please try again later." |
| `unknown` | "An unexpected error occurred. Please try again." |

### Network Retry Logic
- **Automatic Retries**: APIClient handles retries with exponential backoff
- **Max Retries**: 3 attempts
- **Timeout**: 30 seconds per request
- **Retriable Errors**: 5xx server errors, timeout, network connection issues

## Biometric Authentication

### Current Implementation (Task 3.2.2.1.I)
- ✅ Check device biometric capability (Face ID / Touch ID)
- ✅ Display appropriate UI button based on device type
- ✅ Biometric prompt with app-specific reason
- ⏳ **TODO**: Retrieve credentials from Keychain (Task 3.2.2.2.I)
- ⏳ **TODO**: Auto-login after successful biometric auth

### Biometric Types
- **Face ID**: Devices with TrueDepth camera (iPhone X and newer)
- **Touch ID**: Devices with fingerprint sensor (iPhone 8 and earlier, iPad)
- **None**: Simulator or devices without biometric capability

### LocalAuthentication Integration
```swift
import LocalAuthentication

let context = LAContext()
context.evaluatePolicy(
    .deviceOwnerAuthenticationWithBiometrics,
    localizedReason: "Sign in to Bob the Builder"
) { success, error in
    // Handle result
}
```

## Testing

### Unit Tests (`BobTheBuilderTests/Authentication/LoginViewModelTests.swift`)
All tests use `@MainActor` and async/await pattern.

#### Email Validation Tests
- ✅ Invalid email format shows error
- ✅ Valid email shows no error
- ✅ Empty email shows no error

#### Password Validation Tests
- ✅ Short password (< 6 chars) shows error
- ✅ Valid password shows no error
- ✅ Empty password shows no error

#### Login Button State Tests
- ✅ Empty fields disable login
- ✅ Valid credentials enable login
- ✅ Email error disables login
- ✅ Password error disables login
- ✅ Loading state disables login

#### Password Visibility Tests
- ✅ Toggle shows/hides password

#### View State Tests
- ✅ Initial state is idle
- ✅ Error state displays message

### Running Tests
```bash
# Run all tests
cmd+U in Xcode

# Run specific test class
xcodebuild test -scheme BobTheBuilder -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:BobTheBuilderTests/LoginViewModelTests

# Run specific test method
xcodebuild test -scheme BobTheBuilder -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:BobTheBuilderTests/LoginViewModelTests/testEmailValidation_WithInvalidEmail_ShowsError
```

## Manual Testing Checklist

### Form Validation
- [ ] Empty email and password → Login button disabled
- [ ] Enter invalid email (e.g., "test") → Red error message appears after 500ms
- [ ] Enter valid email (e.g., "test@example.com") → Error disappears
- [ ] Enter short password (e.g., "123") → Red error message appears after 500ms
- [ ] Enter valid password (e.g., "password123") → Error disappears
- [ ] Valid credentials → Login button enabled and styled blue

### Login Flow
- [ ] Tap login with valid test credentials → Loading overlay appears
- [ ] Successful login → Navigate to Projects tab
- [ ] Failed login → Error alert appears with clear message
- [ ] Tap outside form → Keyboard dismisses

### Password Visibility
- [ ] Tap eye icon → Password becomes visible (SecureField → TextField)
- [ ] Tap eye.slash icon → Password becomes hidden

### Biometric UI (Device-Dependent)
- [ ] On Face ID device → "Sign in with Face ID" button appears
- [ ] On Touch ID device → "Sign in with Touch ID" button appears
- [ ] On simulator → No biometric button (expected)
- [ ] Tap biometric button → System prompt appears with "Sign in to Bob the Builder"

### Development Features
- [ ] "Skip Login (Dev)" button visible in DEBUG builds only
- [ ] Tap Skip Login → Immediately navigate to Projects tab
- [ ] Production build → Skip button does not appear

### Network Scenarios
- [ ] Valid credentials with backend running → Success
- [ ] Invalid credentials → "Invalid email or password" error
- [ ] Backend not running → "Request timed out" or connection error
- [ ] Airplane mode → "No internet connection" error

## Security Considerations

### Current Implementation (Task 3.2.2.1.I)
- ✅ HTTPS enforced in production (Staging/Prod environments)
- ✅ HTTP allowed only for localhost in development
- ✅ Passwords never logged or displayed in plain text
- ✅ Password visibility toggle for user convenience
- ⚠️ **TEMPORARY**: Tokens stored in UserDefaults (insecure)

### Next Task Security (Task 3.2.2.2.I)
- ⏳ Move tokens to iOS Keychain with encryption
- ⏳ Enable biometric protection for Keychain items
- ⏳ Add token encryption before Keychain storage
- ⏳ Clear all sensitive data on logout

### Production Security Checklist
- [ ] All API calls use HTTPS
- [ ] Tokens stored in Keychain (not UserDefaults)
- [ ] Biometric authentication enabled for sensitive operations
- [ ] No credentials in logs or debug output
- [ ] Certificate pinning implemented (future enhancement)
- [ ] Remove development bypass button (#if DEBUG removed before release)

## Environment Configuration

### Development (Dev.xcconfig)
```
API_BASE_URL = http://localhost:3000/api
ENVIRONMENT = Development
ENABLE_DEBUG_LOGGING = YES
```

### Staging (Stage.xcconfig)
```
API_BASE_URL = https://api-stage.bobthebuilder.com
ENVIRONMENT = Staging
ENABLE_DEBUG_LOGGING = YES
```

### Production (Prod.xcconfig)
```
API_BASE_URL = https://api.bobthebuilder.com
ENVIRONMENT = Production
ENABLE_DEBUG_LOGGING = NO
```

### App Transport Security (Info.plist)
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>localhost</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
        </dict>
    </dict>
</dict>
```

This allows HTTP connections ONLY to localhost for development testing.

## API Endpoints

### Login
**Endpoint**: `POST /api/auth/login`

**Request**:
```json
{
  "email": "user@example.com",
  "password": "securePassword123"
}
```

**Success Response** (200):
```json
{
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "role": "contractor",
    "created_at": "2025-11-01T10:00:00Z",
    "updated_at": "2025-11-09T15:30:00Z"
  },
  "tokens": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expires_in": 3600
  }
}
```

**Error Response** (401):
```json
{
  "message": "Invalid credentials",
  "status_code": 401,
  "error": "Unauthorized"
}
```

### Refresh Token (Future)
**Endpoint**: `POST /api/auth/refresh`

**Request**:
```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Success Response** (200):
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 3600
}
```

### Logout (Future)
**Endpoint**: `POST /api/auth/logout`

**Request**: Empty body (uses Authorization header)

**Success Response** (200): Empty

## Troubleshooting

### Issue: "Request timed out" on login
**Solution**:
- Ensure backend server is running at `http://localhost:3000`
- Check Dev.xcconfig has correct API_BASE_URL
- Verify Info.plist has NSAppTransportSecurity exception for localhost

### Issue: "No internet connection" on simulator
**Solution**:
- Check simulator network settings
- Restart simulator
- Verify Mac network connection

### Issue: Biometric button doesn't appear
**Expected**: Simulator doesn't support Face ID/Touch ID. Test on real device.

### Issue: Login button stays disabled
**Solution**:
- Check email format (must be valid email)
- Check password length (minimum 6 characters)
- Wait 500ms after typing for validation debounce

### Issue: Tokens not persisted after app restart
**Expected**: Current implementation uses UserDefaults (temporary). Will be fixed in Task 3.2.2.2.I with Keychain.

## Next Steps (Upcoming Tasks)

### Task 3.2.2.2.I: Keychain Storage
- Create `KeychainService` wrapper
- Store tokens securely in iOS Keychain
- Enable biometric protection for token access
- Replace UserDefaults with Keychain in LoginViewModel

### Task 3.2.2.3.I: Auth Manager
- Create `AuthService` singleton
- Implement token injection in APIClient
- Add 401 interceptor for automatic token refresh
- Implement logout cleanup coordination

### Task 3.2.2.4.I: Auth Navigation
- Update AppCoordinator to check Keychain on launch
- Implement session expiry handling
- Add deep link authentication checks
- Create protected route enforcement

## References

- [Apple Documentation: LocalAuthentication](https://developer.apple.com/documentation/localauthentication)
- [Apple Documentation: Keychain Services](https://developer.apple.com/documentation/security/keychain_services)
- [JWT.io](https://jwt.io/) - JWT token decoder and documentation
- [OAuth 2.0 RFC](https://tools.ietf.org/html/rfc6749) - Authentication protocol reference

## Change Log

### Version 0.1.0 (2025-11-09) - Task 3.2.2.1.I
- ✅ Created authentication models (User, AuthTokens, LoginRequest, LoginResponse)
- ✅ Implemented LoginAPIRequest, RefreshTokenAPIRequest, LogoutAPIRequest
- ✅ Enhanced LoginViewModel with real-time validation and API integration
- ✅ Updated LoginView with improved UI, error states, and biometric preparation
- ✅ Added comprehensive unit tests for validation logic
- ✅ Configured Dev.xcconfig for local development (localhost:3000)
- ✅ Added NSAppTransportSecurity exception for localhost HTTP
- ✅ Created authentication documentation

### Pending (Task 3.2.2.2.I)
- ⏳ Keychain integration for secure token storage
- ⏳ Biometric authentication implementation
- ⏳ Token encryption before storage

### Pending (Task 3.2.2.3.I)
- ⏳ AuthService singleton
- ⏳ Token injection in API requests
- ⏳ 401 interceptor for token refresh

### Pending (Task 3.2.2.4.I)
- ⏳ Auth-aware navigation
- ⏳ Session expiry handling
- ⏳ Deep link authentication checks
