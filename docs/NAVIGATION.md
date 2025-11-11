# Navigation Architecture

This document describes the authentication-aware navigation system in the Bob the Builder iOS app.

## Table of Contents

1. [Overview](#overview)
2. [Architecture Components](#architecture-components)
3. [Authentication Flow](#authentication-flow)
4. [Navigation Patterns](#navigation-patterns)
5. [Deep Linking](#deep-linking)
6. [Protected Views](#protected-views)
7. [Session Management](#session-management)
8. [Best Practices](#best-practices)
9. [Troubleshooting](#troubleshooting)

---

## Overview

The app uses a coordinator-based navigation architecture with authentication-aware routing. The system ensures that:

- Users can only access protected content when authenticated
- Deep links are stored and processed after authentication
- Session expiry is handled gracefully with re-authentication prompts
- Navigation state is properly managed across app lifecycle events

### Key Features

- **Tab-based Navigation**: Three main tabs (Projects, RFIs, Settings)
- **Stack Navigation**: Each tab maintains its own navigation stack
- **Auth Protection**: Views require authentication before access
- **Deep Linking**: Support for custom URL scheme (`bobthebuilder://`)
- **Session Management**: Automatic token refresh and expiry handling

---

## Architecture Components

### 1. RootView

**File**: `BobTheBuilder/App/RootView.swift`

The main entry point for the app's navigation system. Coordinates the flow between splash screen, onboarding, authentication, and main content.

**Responsibilities**:
- Shows splash screen during initialization
- Routes to onboarding for new users
- Routes to authentication for unauthenticated users
- Shows main content for authenticated users
- Processes pending deep links after authentication

```swift
// Conditional navigation based on auth state
if coordinator.isLoading {
    SplashScreenView()
} else if coordinator.showOnboarding {
    OnboardingView()
} else if !coordinator.isAuthenticated {
    authenticationView
} else {
    MainTabView()
}
```

### 2. AppCoordinator

**File**: `BobTheBuilder/Core/Navigation/AppCoordinator.swift`

The central coordinator that manages app-wide navigation and authentication state.

**Key Properties**:
```swift
@Published var isAuthenticated: Bool          // Current auth state
@Published var isLoading: Bool                // Initial loading state
@Published var showOnboarding: Bool           // First-time user flow
@Published var requiresReauthentication: Bool // Session expired
@Published var appError: AppError?            // Global error handling
```

**Key Methods**:
- `login()`: Called after successful authentication
- `logout()`: Signs out user and resets navigation
- `handleDeepLink(_ url: URL)`: Processes deep links
- `showMessage(title:message:dismissAction:)`: Displays global messages

### 3. NavigationPathManager

**File**: `BobTheBuilder/Core/Navigation/NavigationPath.swift`

Manages navigation stacks for each tab with authentication-aware routing.

**Key Properties**:
```swift
@Published var projectsPath: [NavigationDestination]  // Projects tab stack
@Published var rfisPath: [NavigationDestination]      // RFIs tab stack
@Published var settingsPath: [NavigationDestination]  // Settings tab stack
@Published var selectedTab: TabItem                   // Current tab
@Published var showingAuthRequired: Bool              // Auth prompt state
@Published var returnDestination: NavigationDestination? // Pending destination
```

**Key Methods**:
- `navigate(to:in:)`: Navigate to a destination (auth-aware)
- `continueAfterAuth()`: Process pending navigation after login
- `requiresAuthentication(for:)`: Check if destination needs auth
- `reset()`: Clear all navigation stacks

### 4. ProtectedView

**File**: `BobTheBuilder/Core/Navigation/ProtectedView.swift`

A wrapper view that enforces authentication requirements.

**Usage**:
```swift
ProtectedView(requiresAuth: true) {
    // Your protected content here
}
```

**Behavior**:
- Shows "Authentication Required" screen when not authenticated
- Shows "Session Expired" screen when re-authentication is needed
- Renders content when authenticated and session is valid

---

## Authentication Flow

### Initial App Launch

```
App Launch
    ↓
SplashScreenView (1 second)
    ↓
Check Auth State
    ↓
    ├─→ First Time User → OnboardingView → LoginView
    ├─→ Not Authenticated → LoginView
    └─→ Authenticated → MainTabView
```

### Login Flow

```
LoginView
    ↓
AuthManager.login(email, password)
    ↓
API Request
    ↓
Store Tokens (Keychain)
    ↓
Update Auth State
    ↓
AppCoordinator.login()
    ↓
MainTabView
    ↓
Process Pending Deep Links (if any)
```

### Logout Flow

```
User Taps Sign Out
    ↓
AppCoordinator.logout()
    ↓
AuthManager.logout()
    ↓
Clear Tokens (Keychain)
    ↓
Reset Navigation Stacks
    ↓
Update Auth State
    ↓
LoginView
```

---

## Navigation Patterns

### Basic Navigation

Navigate to a destination within the current tab:

```swift
let navigationManager = NavigationPathManager.shared
navigationManager.navigate(to: .projectDetail(projectId: "123"))
```

### Cross-Tab Navigation

Navigate to a destination in a different tab:

```swift
navigationManager.navigate(to: .rfiDetail(rfiId: "456"), in: .rfis)
// Switches to RFIs tab and pushes detail view
```

### Auth-Aware Navigation

The system automatically handles authentication requirements:

```swift
// If user is not authenticated:
navigationManager.navigate(to: .projectDetail(projectId: "123"))
// → Shows "Authentication Required" prompt
// → Stores destination for after login
// → After login: automatically navigates to destination
```

### Navigation Destinations

Available destinations defined in `NavigationDestination`:

```swift
enum NavigationDestination {
    case projectDetail(projectId: String)  // Requires auth
    case rfiDetail(rfiId: String)          // Requires auth
    case createProject                     // Requires auth
    case createRFI(projectId: String)      // Requires auth
    case profile                           // Requires auth
    case settings                          // Requires auth
    case about                             // No auth required
}
```

---

## Deep Linking

### URL Scheme

The app supports the `bobthebuilder://` custom URL scheme.

**Configuration**: `BobTheBuilder/App/Info.plist`

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.bobthebuilder.app</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>bobthebuilder</string>
        </array>
    </dict>
</array>
```

### Supported Deep Links

| Pattern | Description | Requires Auth |
|---------|-------------|---------------|
| `bobthebuilder://project/{id}` | Open project detail | Yes |
| `bobthebuilder://rfi/{id}` | Open RFI detail | Yes |
| `bobthebuilder://settings` | Open settings | Yes |
| `bobthebuilder://profile` | Open profile | Yes |

### Deep Link Examples

```bash
# Open project detail
bobthebuilder://project/abc123

# Open RFI detail
bobthebuilder://rfi/rfi-456

# Open settings
bobthebuilder://settings

# Open profile
bobthebuilder://profile
```

### Implementation

Deep links are handled in `AppDelegate`:

```swift
func application(_ app: UIApplication, open url: URL, ...) -> Bool {
    AppCoordinator.shared.handleDeepLink(url)
    return true
}
```

### Authentication and Deep Links

When a deep link is received but the user is not authenticated:

1. Deep link is parsed and validated
2. Destination is stored in `AppCoordinator.pendingDeepLink`
3. User is prompted to authenticate
4. After successful login, pending deep link is processed
5. User is navigated to the requested destination

**Example Flow**:
```
Deep Link: bobthebuilder://project/123
    ↓
User Not Authenticated
    ↓
Store: pendingDeepLink = .projectDetail(projectId: "123")
    ↓
Show LoginView
    ↓
User Logs In
    ↓
Process Pending Deep Link
    ↓
Navigate to Project Detail (ID: 123)
```

### Testing Deep Links

#### Simulator
```bash
xcrun simctl openurl booted "bobthebuilder://project/123"
```

#### Device (via Safari)
1. Create an HTML file with the deep link
2. Host it on a local server or use a note
3. Tap the link in Safari

---

## Protected Views

### Using ProtectedView Wrapper

All sensitive views should be wrapped with `ProtectedView`:

```swift
struct MyProtectedView: View {
    var body: some View {
        ProtectedView(requiresAuth: true) {
            // Your content here
        }
    }
}
```

### Current Protected Views

The following views are wrapped with `ProtectedView`:
- **ProjectListView**: `/Features/Projects/ProjectListView.swift:16`
- **RFIListView**: `/Features/RFI/RFIListView.swift:17`
- **SettingsView**: `/Features/Settings/SettingsView.swift:18`

### Defense-in-Depth

Even though `MainTabView` is only shown when authenticated, individual views are also protected to ensure:
- Direct navigation attempts are blocked
- Views used in different contexts remain secure
- Session expiry is handled at the view level

---

## Session Management

### Token Refresh

**File**: `BobTheBuilder/Core/Auth/AuthManager.swift`

The system automatically refreshes authentication tokens:

- Tokens are refreshed **5 minutes before expiry**
- Refresh happens in the background
- On 401 responses, a single retry with token refresh is attempted
- Failed refresh triggers re-authentication flow

### Session Expiry

When a session expires:

1. `AppCoordinator.requiresReauthentication` is set to `true`
2. Protected views show "Session Expired" screen
3. User is prompted to sign in again
4. Navigation state is preserved during re-authentication

### Background Timeout

When the app is backgrounded:

- A 5-minute timeout is scheduled
- If the app returns before timeout: continue normally
- If timeout occurs while backgrounded: require re-authentication on return

**Implementation**: `AppCoordinator.handleAppWillResignActive()`

```swift
private func handleAppWillResignActive() {
    let workItem = DispatchWorkItem { [weak self] in
        self?.handleSessionTimeout()
    }
    sessionExpiryWorkItem = workItem
    DispatchQueue.main.asyncAfter(deadline: .now() + 300, execute: workItem)
}
```

---

## Best Practices

### 1. Use NavigationPathManager for All Navigation

❌ **Don't** use direct SwiftUI navigation:
```swift
// Bad
@State private var isShowingDetail = false
NavigationLink(destination: DetailView(), isActive: $isShowingDetail)
```

✅ **Do** use NavigationPathManager:
```swift
// Good
navigationManager.navigate(to: .projectDetail(projectId: id))
```

### 2. Always Check Authentication for Sensitive Operations

```swift
func loadProjects() {
    guard authManager.isAuthenticated else {
        viewState = .error(AuthError.sessionExpired)
        return
    }
    // Load projects
}
```

### 3. Handle Deep Links Gracefully

```swift
func handleDeepLink(_ url: URL) {
    guard let destination = parseDeepLink(url) else {
        print("❌ Failed to parse deep link")
        return
    }

    if isAuthenticated {
        navigateToDestination(destination)
    } else {
        pendingDeepLink = destination
        print("📌 Deep link saved for after authentication")
    }
}
```

### 4. Use Descriptive Logging

Include emojis in logs for easy scanning:
- ✅ Success
- ❌ Error
- 🔄 In Progress
- 📌 Stored/Saved
- 🔗 Deep Link
- 🚪 Logout
- ⚠️ Warning

```swift
print("✅ User authenticated: \(user.email)")
print("🔗 Handling deep link: \(url)")
print("❌ Failed to parse deep link")
```

---

## Troubleshooting

### Issue: Deep Link Not Working

**Symptoms**: Deep links don't open the app or navigate correctly

**Solutions**:
1. Verify URL scheme is registered in Info.plist
2. Check AppDelegate is properly configured
3. Ensure URL format matches expected pattern
4. Test with simulator: `xcrun simctl openurl booted "bobthebuilder://..."`

**Debug**:
```swift
func handleDeepLink(_ url: URL) {
    print("🔗 Handling deep link: \(url)")
    print("Scheme: \(url.scheme ?? "none")")
    print("Host: \(url.host ?? "none")")
    print("Path: \(url.path)")
}
```

### Issue: User Stuck in Authentication Loop

**Symptoms**: User logs in successfully but is immediately logged out

**Solutions**:
1. Check token storage in Keychain
2. Verify token refresh logic
3. Check for conflicting auth state updates
4. Review notification subscriptions in AppCoordinator

**Debug**:
```swift
// In AuthManager
print("🔐 Storing tokens...")
try? KeychainManager.shared.save(token: authResponse.token, for: .accessToken)
print("✅ Tokens stored successfully")

// In AppCoordinator
private func handleAuthStateChange(_ state: AuthState) {
    print("📊 Auth state changed: \(state)")
}
```

### Issue: Navigation Stack Not Cleared on Logout

**Symptoms**: After logout and re-login, old navigation stack is visible

**Solutions**:
1. Ensure `NavigationPathManager.reset()` is called on logout
2. Verify notification subscription for `.userLoggedOut`
3. Check that navigation stacks are properly cleared

**Debug**:
```swift
// In NavigationPathManager
private func handleLogout() {
    print("🗑️ Clearing navigation stacks...")
    print("Projects stack: \(projectsPath.count) items")
    print("RFIs stack: \(rfisPath.count) items")
    print("Settings stack: \(settingsPath.count) items")
    reset()
    print("✅ Navigation stacks cleared")
}
```

### Issue: Protected View Shows Even When Authenticated

**Symptoms**: ProtectedView displays "Authentication Required" despite being logged in

**Solutions**:
1. Check `AuthManager.isAuthenticated` property
2. Verify token is properly stored in Keychain
3. Ensure AuthManager is checking tokens on initialization
4. Check that StateObject is used (not State) for AuthManager

**Debug**:
```swift
// In ProtectedView
var body: some View {
    Group {
        let _ = print("🔒 ProtectedView - isAuthenticated: \(authManager.isAuthenticated)")
        let _ = print("🔒 ProtectedView - requiresReauthentication: \(coordinator.requiresReauthentication)")

        if requiresAuth && !authManager.isAuthenticated {
            unauthorizedView
        } else if coordinator.requiresReauthentication {
            reauthenticationView
        } else {
            content
        }
    }
}
```

### Issue: Session Expires Too Quickly

**Symptoms**: User is frequently asked to re-authenticate

**Solutions**:
1. Check background timeout duration (currently 5 minutes)
2. Verify token refresh window (currently 5 minutes before expiry)
3. Review API token expiration settings
4. Check if app is being terminated in background

**Configuration**:
```swift
// Background timeout in AppCoordinator
DispatchQueue.main.asyncAfter(deadline: .now() + 300, execute: workItem) // 5 min

// Token refresh window in AuthManager
if timeUntilExpiry < 300 { // 5 minutes before expiry
    await refreshAuthToken()
}
```

### Issue: Pending Deep Link Not Processed After Login

**Symptoms**: User logs in after receiving a deep link, but isn't navigated to destination

**Solutions**:
1. Verify `pendingDeepLink` is stored correctly
2. Check that `handleAuthStateChange` processes pending deep links
3. Ensure delay is sufficient for navigation setup
4. Review logs for deep link processing

**Debug**:
```swift
// In AppCoordinator
case .authenticated(let user):
    print("✅ User authenticated: \(user.email)")
    if let pendingDeepLink = pendingDeepLink {
        print("🔄 Processing pending deep link: \(pendingDeepLink)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.navigateToDestination(pendingDeepLink)
            self.pendingDeepLink = nil
            print("✅ Pending deep link processed")
        }
    }
}
```

---

## Related Documentation

- [API Integration Guide](./API_INTEGRATION.md)
- [Architecture Overview](./ARCHITECTURE.md)
- [Authentication System](./AUTH.md)

---

**Last Updated**: November 9, 2025
