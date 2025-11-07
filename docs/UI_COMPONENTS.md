# UI Components Guide

This guide documents the reusable UI components and patterns used throughout the Bob the Builder iOS app.

## Table of Contents

1. [ViewState Pattern](#viewstate-pattern)
2. [State Views](#state-views)
3. [Custom Text Field Style](#custom-text-field-style)
4. [View Models](#view-models)
5. [Usage Examples](#usage-examples)

## ViewState Pattern

The `ViewState` enum provides a consistent way to manage view states across all features in the app.

### Definition

```swift
enum ViewState<T> {
    case idle
    case loading
    case loaded(T)
    case empty
    case error(Error)
}
```

### States

- **idle**: Initial state before any data loading
- **loading**: Data is being fetched from the network or local storage
- **loaded(T)**: Data has been successfully loaded with associated value
- **empty**: No data available (e.g., empty list)
- **error(Error)**: An error occurred with associated error value

### Helper Properties

```swift
var isLoading: Bool       // Returns true if state is .loading
var data: T?              // Returns the loaded data if available
var error: Error?         // Returns the error if state is .error
var isEmpty: Bool         // Returns true if state is .empty
var isIdle: Bool          // Returns true if state is .idle
```

### Benefits

- **Consistency**: All views handle states the same way
- **Type Safety**: Generic type parameter ensures correct data types
- **Exhaustive**: Forces handling of all possible states
- **Testability**: Easy to test different states in isolation

## State Views

Reusable SwiftUI views for displaying different states consistently across the app.

### LoadingStateView

Displays a loading spinner with an optional message.

```swift
LoadingStateView(message: "Loading projects...")
```

**Parameters:**
- `message`: String - Loading message (default: "Loading...")

**Use When:**
- Fetching data from network
- Performing long-running operations
- Waiting for API responses

### EmptyStateView

Displays an empty state with icon, title, message, and optional action button.

```swift
EmptyStateView(
    icon: "hammer.fill",
    title: "No Projects Yet",
    message: "Tap + to create your first project",
    actionTitle: "Create Project",
    action: {
        // Action to perform
    }
)
```

**Parameters:**
- `icon`: String - SF Symbol name
- `title`: String - Main title
- `message`: String - Descriptive message
- `actionTitle`: String? - Button title (optional)
- `action`: (() -> Void)? - Action to perform when button tapped (optional)

**Use When:**
- List or collection has no items
- Search returns no results
- User hasn't created content yet

### ErrorStateView

Displays an error message with optional retry functionality.

```swift
ErrorStateView(
    error: "Failed to load projects",
    retry: {
        viewModel.loadProjects()
    }
)
```

**Parameters:**
- `error`: String - Error message to display
- `retry`: (() -> Void)? - Retry action (optional)

**Use When:**
- Network request fails
- Data loading encounters an error
- Operation fails and user can retry

## Custom Text Field Style

A custom text field style that adds an icon to the left of the text field.

### Usage

```swift
TextField("Email", text: $email)
    .textFieldStyle(CustomTextFieldStyle(systemImage: "envelope"))

SecureField("Password", text: $password)
    .textFieldStyle(CustomTextFieldStyle(systemImage: "lock"))
```

**Parameters:**
- `systemImage`: String - SF Symbol name to display as icon

**Features:**
- Consistent padding and spacing
- Gray icon color for subtle appearance
- Rounded corners with background color
- Works with both TextField and SecureField

## View Models

All major views use the MVVM pattern with ObservableObject view models.

### Pattern

```swift
class SomeViewModel: ObservableObject {
    @Published var viewState: ViewState<DataType> = .idle

    func loadData() {
        guard viewState.isIdle else { return }

        viewState = .loading

        Task {
            // Simulate or perform API call
            try? await Task.sleep(nanoseconds: 1_000_000_000)

            await MainActor.run {
                let data = fetchData()

                if data.isEmpty {
                    viewState = .empty
                } else {
                    viewState = .loaded(data)
                }
            }
        }
    }

    func refreshData() async {
        // Refresh without showing loading state
        try? await Task.sleep(nanoseconds: 500_000_000)

        await MainActor.run {
            let data = fetchData()

            if data.isEmpty {
                viewState = .empty
            } else {
                viewState = .loaded(data)
            }
        }
    }
}
```

### Key Features

- **@Published viewState**: Automatically updates the view when state changes
- **loadData()**: Initial data load with loading state
- **refreshData()**: Refresh data without loading spinner (for pull-to-refresh)
- **Async/await**: Modern Swift concurrency for asynchronous operations
- **MainActor.run**: Ensures UI updates happen on the main thread

## Usage Examples

### Example 1: List View with ViewState

```swift
struct ProjectListView: View {
    @StateObject private var viewModel = ProjectListViewModel()

    var body: some View {
        ZStack {
            if viewModel.viewState.isLoading {
                LoadingStateView(message: "Loading projects...")
            } else if viewModel.viewState.isEmpty {
                EmptyStateView(
                    icon: "hammer.fill",
                    title: "No Projects Yet",
                    message: "Tap + to create your first project",
                    actionTitle: "Create Project",
                    action: {
                        // Navigate to create project
                    }
                )
            } else if let error = viewModel.viewState.error {
                ErrorStateView(
                    error: error.localizedDescription,
                    retry: {
                        viewModel.loadProjects()
                    }
                )
            } else if let projects = viewModel.viewState.data {
                projectList(projects: projects)
            }
        }
        .onAppear {
            viewModel.loadProjects()
        }
        .refreshable {
            await viewModel.refreshProjects()
        }
    }

    private func projectList(projects: [Project]) -> some View {
        List(projects) { project in
            ProjectRow(project: project)
        }
    }
}
```

### Example 2: Form View with Loading State

```swift
struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        ZStack {
            if viewModel.viewState.isLoading {
                LoadingStateView(message: "Signing in...")
            } else {
                loginForm
            }
        }
        .alert("Login Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }

    private var loginForm: some View {
        VStack(spacing: 16) {
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(CustomTextFieldStyle(systemImage: "envelope"))

            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(CustomTextFieldStyle(systemImage: "lock"))

            Button("Sign In") {
                viewModel.login()
            }
            .disabled(!viewModel.canLogin)
        }
    }
}
```

### Example 3: Filtering and Search

```swift
struct RFIListView: View {
    @StateObject private var viewModel = RFIListViewModel()
    @State private var searchText = ""
    @State private var filterStatus: RFIFilterStatus = .all

    var body: some View {
        ZStack {
            // State handling...
            if let rfis = viewModel.viewState.data {
                rfiList(rfis: rfis)
            }
        }
    }

    private func rfiList(rfis: [RFI]) -> some View {
        List {
            Section {
                Picker("Filter", selection: $filterStatus) {
                    ForEach(RFIFilterStatus.allCases, id: \.self) { status in
                        Text(status.rawValue).tag(status)
                    }
                }
                .pickerStyle(.segmented)
            }

            ForEach(filteredRFIs(rfis)) { rfi in
                RFIRow(rfi: rfi)
            }
        }
        .searchable(text: $searchText, prompt: "Search RFIs")
    }

    private func filteredRFIs(_ rfis: [RFI]) -> [RFI] {
        var filtered = rfis

        // Apply status filter
        if filterStatus != .all {
            filtered = filtered.filter { $0.status == mapFilterToStatus(filterStatus) }
        }

        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.subject.localizedCaseInsensitiveContains(searchText) }
        }

        return filtered
    }
}
```

## Best Practices

### 1. Always Handle All States

When using ViewState, always handle all possible states in your view:

```swift
ZStack {
    if viewModel.viewState.isLoading {
        LoadingStateView()
    } else if viewModel.viewState.isEmpty {
        EmptyStateView(...)
    } else if let error = viewModel.viewState.error {
        ErrorStateView(...)
    } else if let data = viewModel.viewState.data {
        contentView(data: data)
    }
}
```

### 2. Use Pull-to-Refresh

Implement pull-to-refresh for better UX:

```swift
.refreshable {
    await viewModel.refreshData()
}
```

### 3. Guard Against Multiple Loads

Prevent multiple simultaneous load operations:

```swift
func loadData() {
    guard viewState.isIdle else { return }
    viewState = .loading
    // ... rest of loading logic
}
```

### 4. Separate Loading from Refresh

Use different methods for initial load (with loading state) and refresh (without loading state):

```swift
func loadData() {
    viewState = .loading
    // ...
}

func refreshData() async {
    // Don't set .loading state
    // Just update the data directly
}
```

### 5. Use MainActor for UI Updates

Always wrap UI state updates in MainActor.run when in async context:

```swift
Task {
    let data = await fetchData()

    await MainActor.run {
        viewState = .loaded(data)
    }
}
```

### 6. Provide Meaningful Messages

Customize loading and error messages to be specific and helpful:

```swift
LoadingStateView(message: "Loading your projects...")
ErrorStateView(error: "Unable to connect to server. Please check your internet connection.")
```

## Testing

### Testing ViewState

```swift
func testViewStateTransitions() {
    let viewModel = ProjectListViewModel()

    // Initial state
    XCTAssertTrue(viewModel.viewState.isIdle)

    // After loading
    viewModel.loadProjects()
    XCTAssertTrue(viewModel.viewState.isLoading)

    // After success
    // ... test loaded state
}
```

### Testing Empty States

```swift
func testEmptyState() {
    let viewModel = ProjectListViewModel()
    // Mock empty data
    viewModel.loadProjects()
    // ... assert empty state
}
```

### Testing Error States

```swift
func testErrorState() {
    let viewModel = ProjectListViewModel()
    // Mock error condition
    viewModel.loadProjects()
    // ... assert error state
}
```

## Component Locations

- **ViewState**: `BobTheBuilder/Shared/Models/ViewState.swift`
- **State Views**: `BobTheBuilder/Shared/Components/StateViews.swift`
- **Custom Text Field**: `BobTheBuilder/Shared/Components/CustomTextFieldStyle.swift`
- **Example ViewModels**:
  - `BobTheBuilder/Features/Authentication/LoginView.swift`
  - `BobTheBuilder/Features/Projects/ProjectListView.swift`
  - `BobTheBuilder/Features/RFI/RFIListView.swift`

## Related Documentation

- [Architecture Overview](ARCHITECTURE.md)
- [Contributing Guide](CONTRIBUTING.md)
- [Project Runbook](RUNBOOK.md)
