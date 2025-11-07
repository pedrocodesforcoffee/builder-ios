# Architecture Overview - Builder iOS

## App Architecture

Builder iOS follows MVVM-C (Model-View-ViewModel-Coordinator) architecture pattern for clean separation of concerns and improved testability.

## Architecture Diagram

```
┌─────────────────────────────────────────┐
│              View Layer                  │
│   ┌─────────────────────────────────┐   │
│   │    UIKit / SwiftUI Views        │   │
│   │    - ViewControllers            │   │
│   │    - SwiftUI Views              │   │
│   │    - Custom UI Components       │   │
│   └──────────┬──────────────────────┘   │
└──────────────┼──────────────────────────┘
               │
               ▼
┌──────────────────────────────────────────┐
│          ViewModel Layer                  │
│   ┌─────────────────────────────────┐    │
│   │   ViewModels (Business Logic)   │    │
│   │   - Data transformation         │    │
│   │   - Validation                  │    │
│   │   - UI state management         │    │
│   └──────────┬──────────────────────┘    │
└──────────────┼───────────────────────────┘
               │
               ▼
┌──────────────────────────────────────────┐
│          Coordinator Layer                │
│   ┌─────────────────────────────────┐    │
│   │    Navigation Coordinators      │    │
│   │    - Flow coordination          │    │
│   │    - Screen transitions         │    │
│   └──────────┬──────────────────────┘    │
└──────────────┼───────────────────────────┘
               │
               ▼
┌──────────────────────────────────────────┐
│           Service Layer                   │
│   ┌──────────┬──────────┬─────────────┐  │
│   │   API    │ Storage  │  Analytics  │  │
│   │ Service  │ Service  │   Service   │  │
│   └────┬─────┴─────┬────┴─────┬───────┘  │
└────────┼───────────┼──────────┼──────────┘
         │           │          │
         ▼           ▼          ▼
┌────────────┐ ┌────────────┐ ┌────────────┐
│  Network   │ │ Core Data  │ │  Firebase  │
│ URLSession │ │  Storage   │ │ Analytics  │
└────────────┘ └────────────┘ └────────────┘
```

## MVVM-C Pattern

### Model
- Data structures (DTOs, Core Data entities)
- Business domain objects
- No UI logic

```swift
struct Project: Codable {
    let id: String
    let name: String
    let status: ProjectStatus
    let startDate: Date
    let endDate: Date?
}
```

### View
- UIKit ViewControllers or SwiftUI Views
- UI rendering and user interaction
- Binds to ViewModel
- No business logic

```swift
class ProjectListViewController: UIViewController {
    private let viewModel: ProjectListViewModel
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }

    private func bindViewModel() {
        viewModel.projects
            .receive(on: DispatchQueue.main)
            .sink { [weak self] projects in
                self?.updateUI(with: projects)
            }
            .store(in: &cancellables)
    }
}
```

### ViewModel
- Business logic and data transformation
- Exposes data via Combine publishers
- Communicates with services
- Platform-independent (testable)

```swift
class ProjectListViewModel {
    @Published private(set) var projects: [Project] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?

    private let apiService: APIServiceProtocol
    private let storageService: StorageServiceProtocol

    func fetchProjects() {
        isLoading = true

        apiService.fetchProjects()
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.error = error
                    }
                },
                receiveValue: { [weak self] projects in
                    self?.projects = projects
                    self?.storageService.save(projects)
                }
            )
            .store(in: &cancellables)
    }
}
```

### Coordinator
- Navigation flow management
- Screen transitions
- Dependency injection for views

```swift
protocol ProjectCoordinatorProtocol {
    func start()
    func showProjectDetail(_ project: Project)
    func showProjectForm()
}

class ProjectCoordinator: ProjectCoordinatorProtocol {
    private let navigationController: UINavigationController
    private let services: ServiceContainer

    func start() {
        let viewModel = ProjectListViewModel(
            apiService: services.apiService,
            storageService: services.storageService
        )
        let viewController = ProjectListViewController(viewModel: viewModel)
        viewController.coordinator = self
        navigationController.pushViewController(viewController, animated: true)
    }

    func showProjectDetail(_ project: Project) {
        // Create and show detail screen
    }
}
```

## Project Structure

### App Layer
- **AppDelegate:** App lifecycle, setup
- **SceneDelegate:** Scene management, window setup
- **AppCoordinator:** Root navigation coordinator

### Core Layer
- **Network:** API client, request/response handling
- **Storage:** Core Data stack, Keychain wrapper
- **Extensions:** Swift standard library extensions
- **Utilities:** Helper functions and utilities

### Features Layer
Each feature module contains:
- **ViewControllers:** UI screens
- **ViewModels:** Business logic
- **Coordinators:** Navigation
- **Models:** Feature-specific models

```
Features/
├── Authentication/
│   ├── LoginViewController.swift
│   ├── LoginViewModel.swift
│   ├── AuthCoordinator.swift
│   └── Models/
├── Dashboard/
│   ├── DashboardViewController.swift
│   ├── DashboardViewModel.swift
│   └── DashboardCoordinator.swift
└── Projects/
    ├── ProjectListViewController.swift
    ├── ProjectDetailViewController.swift
    ├── ProjectViewModel.swift
    └── ProjectCoordinator.swift
```

## Data Flow

### 1. User Interaction
```
User taps button → View captures event → ViewModel method called
```

### 2. Data Fetching
```
ViewModel → Service → API/Storage → Response → ViewModel → View Update
```

### 3. Offline-First Flow
```
1. Check local storage (Core Data)
2. Display cached data immediately
3. Fetch from API in background
4. Update local storage
5. Notify view of changes
```

## Networking Layer

### API Client
```swift
protocol APIServiceProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) -> AnyPublisher<T, Error>
}

class APIService: APIServiceProtocol {
    private let session: URLSession
    private let baseURL: URL

    func request<T: Decodable>(_ endpoint: Endpoint) -> AnyPublisher<T, Error> {
        let request = buildRequest(for: endpoint)

        return session.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
```

### Endpoint Definition
```swift
enum Endpoint {
    case projects
    case projectDetail(id: String)
    case createProject(data: ProjectDTO)

    var path: String {
        switch self {
        case .projects: return "/projects"
        case .projectDetail(let id): return "/projects/\(id)"
        case .createProject: return "/projects"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .projects, .projectDetail: return .get
        case .createProject: return .post
        }
    }
}
```

## Storage Layer

### Core Data Stack
```swift
class CoreDataStack {
    static let shared = CoreDataStack()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "BobTheBuilder")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data failed: \(error)")
            }
        }
        return container
    }()

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func saveContext() {
        let context = viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Handle error
            }
        }
    }
}
```

### Repository Pattern
```swift
protocol ProjectRepositoryProtocol {
    func fetchAll() -> [Project]
    func fetch(by id: String) -> Project?
    func save(_ project: Project)
    func delete(_ project: Project)
}

class ProjectRepository: ProjectRepositoryProtocol {
    private let context: NSManagedObjectContext

    func fetchAll() -> [Project] {
        let request: NSFetchRequest<ProjectEntity> = ProjectEntity.fetchRequest()
        let entities = try? context.fetch(request)
        return entities?.map { $0.toDomainModel() } ?? []
    }
}
```

## Dependency Injection

### Service Container
```swift
class ServiceContainer {
    lazy var apiService: APIServiceProtocol = {
        APIService(baseURL: Configuration.apiBaseURL)
    }()

    lazy var storageService: StorageServiceProtocol = {
        CoreDataStorage(context: CoreDataStack.shared.viewContext)
    }()

    lazy var authService: AuthServiceProtocol = {
        AuthService(
            apiService: apiService,
            keychainService: keychainService
        )
    }()

    // ... other services
}
```

## UI Framework Strategy

### UIKit (Primary)
- ViewControllers for main screens
- UITableView/UICollectionView for lists
- Custom UIViews for components
- Programmatic Auto Layout or SnapKit

### SwiftUI (Supplementary)
- Small, self-contained views
- Settings screens
- Simple forms
- Preview for development

### Hybrid Approach
```swift
// SwiftUI view hosted in UIKit
import SwiftUI

class SettingsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let settingsView = SettingsView()
        let hostingController = UIHostingController(rootView: settingsView)

        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
}
```

## Testing Strategy

### Unit Tests
- ViewModels (business logic)
- Services (API, storage)
- Utilities and extensions
- Use mocks for dependencies

```swift
class ProjectViewModelTests: XCTestCase {
    var sut: ProjectListViewModel!
    var mockAPIService: MockAPIService!
    var mockStorageService: MockStorageService!

    override func setUp() {
        mockAPIService = MockAPIService()
        mockStorageService = MockStorageService()
        sut = ProjectListViewModel(
            apiService: mockAPIService,
            storageService: mockStorageService
        )
    }

    func testFetchProjectsSuccess() {
        // Given
        let expectedProjects = [Project.mock()]
        mockAPIService.projectsToReturn = expectedProjects

        // When
        sut.fetchProjects()

        // Then
        XCTAssertEqual(sut.projects, expectedProjects)
    }
}
```

### UI Tests
- Critical user flows
- End-to-end testing
- Accessibility testing

```swift
class ProjectFlowUITests: XCTestCase {
    func testCreateProject() {
        let app = XCUIApplication()
        app.launch()

        // Navigate to create project
        app.buttons["New Project"].tap()

        // Fill form
        let nameField = app.textFields["Project Name"]
        nameField.tap()
        nameField.typeText("New Construction Site")

        // Submit
        app.buttons["Create"].tap()

        // Verify
        XCTAssertTrue(app.staticTexts["New Construction Site"].exists)
    }
}
```

## Performance Optimization

### Image Handling
- Lazy loading with placeholder
- Image caching with NSCache
- Background decompression
- Appropriate image sizes

### List Performance
- Cell reuse
- Prefetching
- Image loading cancellation
- Batch updates

### Memory Management
- Weak references in closures
- Automatic cache cleanup
- Background context for Core Data
- Proper deinitialization

## Security

### Authentication
- JWT tokens in Keychain
- Biometric authentication
- Automatic token refresh
- Secure session management

### Data Protection
- Encrypted Core Data
- Keychain for sensitive data
- Certificate pinning for API
- No sensitive data in logs

## Build Configurations

### Development
- Debug logging enabled
- Test servers
- Relaxed certificate validation
- Analytics disabled

### Staging
- Production-like environment
- Full logging
- Analytics enabled
- Crash reporting enabled

### Production
- Optimized builds
- Minimal logging
- Analytics enabled
- Crash reporting enabled
- App Store configuration

## API Client Architecture

### Overview

The API client provides a robust networking layer with comprehensive features:
- **Async/await** and **Combine** support for flexible integration
- **Automatic retry logic** with exponential backoff for transient errors
- **Comprehensive logging** with NetworkLogger for debugging
- **Mock client** for reliable unit testing
- **Type-safe** request/response handling via protocols

### Components

#### APIRequest Protocol

Defines the contract for all API requests:
- **Path**: API endpoint path
- **Method**: HTTP method (GET, POST, PUT, PATCH, DELETE)
- **Headers**: Custom HTTP headers
- **Parameters**: URL query parameters
- **Body**: Request body data
- **Timeout**: Request timeout (default: 30s)
- **MaxRetries**: Maximum retry attempts (default: 3)

```swift
struct LoginRequest: APIRequest {
    typealias Response = LoginResponse
    
    let email: String
    let password: String
    
    var path: String { "/auth/login" }
    var method: HTTPMethod { .post }
    var body: Data? {
        try? JSONEncoder().encode(["email": email, "password": password])
    }
}
```

#### APIClient

Main networking implementation:
- **URLSession-based**: Uses Apple's standard networking APIs
- **Environment-aware**: Automatically uses correct API URL from AppConfiguration
- **Automatic retry**: Retries transient errors (timeout, network, 5xx)
- **Exponential backoff**: Delay increases with each retry (1s, 2s, 4s...)
- **Request/response logging**: Detailed logs via NetworkLogger

```swift
// Execute request with async/await
let request = LoginRequest(email: "user@example.com", password: "secure123")
let response = try await APIClient.shared.execute(request)

// Or use Combine
APIClient.shared.execute(request)
    .sink(
        receiveCompletion: { completion in
            // Handle completion
        },
        receiveValue: { response in
            // Handle response
        }
    )
    .store(in: &cancellables)
```

#### MockAPIClient

Testing implementation for unit tests:
- **Simulates network delays**: Configurable delay for realistic testing
- **Configurable responses and errors**: Set expected responses or errors per endpoint
- **Request tracking**: Logs all requests for assertions
- **No network calls**: Fast, reliable tests without external dependencies

```swift
// Setup mock
let mockClient = MockAPIClient()
mockClient.requestDelay = 0.1

// Configure response
let expectedResponse = LoginResponse(token: "mock-token", userId: "123")
mockClient.setMockResponse(expectedResponse, for: .post, path: "/auth/login")

// Execute and test
let request = LoginRequest(email: "test@example.com", password: "password")
let response = try await mockClient.execute(request)

XCTAssertEqual(response.token, "mock-token")
XCTAssertEqual(mockClient.requestLog.count, 1)
```

### Error Handling

APIError enum provides specific, actionable error cases:

**Network Errors:**
- `.timeout` - Request timed out (retriable)
- `.noInternetConnection` - No network available (retriable)
- `.networkError(Error)` - General network error (retriable)

**HTTP Errors:**
- `.unauthorized` - 401 status (not retriable)
- `.httpError(statusCode, data)` - 4xx client errors (not retriable)
- `.serverError(message)` - 5xx server errors (retriable)

**Data Errors:**
- `.invalidURL` - Malformed URL (not retriable)
- `.noData` - Empty response (not retriable)
- `.decodingError(Error)` - JSON decoding failed (not retriable)

```swift
do {
    let response = try await APIClient.shared.execute(request)
    // Handle success
} catch let error as APIError {
    switch error {
    case .unauthorized:
        // Navigate to login
    case .noInternetConnection:
        // Show offline banner
    case .httpError(let statusCode, _):
        // Show error message based on status code
    default:
        // Show generic error
    }
}
```

### Logging with NetworkLogger

NetworkLogger provides detailed, formatted logs for debugging:

**Request Logging:**
```
[14:23:45.123] 🚀 POST https://api-dev.bobthebuilder.com/auth/login
📋 Headers: ["Content-Type": "application/json", "User-Agent": "iOS/0.1.0"]
📦 Body: {"email":"user@example.com","password":"********"}
```

**Response Logging:**
```
[14:23:45.456] ✅ 200 https://api-dev.bobthebuilder.com/auth/login
📦 Response size: 256 bytes
📄 Response: {"token":"jwt-token-here","user_id":"123"}
```

**Status Emojis:**
- ✅ 2xx - Success
- ↩️ 3xx - Redirect
- ⚠️ 4xx - Client error
- 🔥 5xx - Server error
- ❓ Other - Unknown status

Logs are visible in:
- **Xcode Console**: During development
- **Console.app**: Filter by "com.bobthebuilder.app" subsystem
- **OSLog**: Integrated with system logging

### Retry Logic

APIClient automatically retries transient errors:

1. **Retriable Errors**: timeout, networkError, noInternetConnection, 5xx status codes
2. **Non-Retriable**: 4xx errors, unauthorized, decodingError, invalidURL
3. **Exponential Backoff**: Delay = 1s × 2^(attempt-1)
   - Attempt 1: 0s delay (initial request)
   - Attempt 2: 1s delay
   - Attempt 3: 2s delay
   - Attempt 4: 4s delay
4. **Max Retries**: Configurable per request (default: 3)

```swift
// Logs when retrying:
[14:23:45.789] 🔄 Retrying request (attempt 2/4) after 1.0s
[14:23:46.789] 🔄 Retrying request (attempt 3/4) after 2.0s
```

### Testing Strategy

#### Unit Tests with MockAPIClient

```swift
class ProjectServiceTests: XCTestCase {
    var mockClient: MockAPIClient!
    var service: ProjectService!
    
    override func setUp() {
        mockClient = MockAPIClient()
        mockClient.requestDelay = 0.1
        service = ProjectService(apiClient: mockClient)
    }
    
    func testFetchProjects() async throws {
        // Arrange
        let mockProjects = [
            Project(id: "1", name: "Test Project", status: .active)
        ]
        mockClient.setMockResponse(mockProjects, for: .get, path: "/projects")
        
        // Act
        let projects = try await service.fetchProjects()
        
        // Assert
        XCTAssertEqual(projects.count, 1)
        XCTAssertEqual(projects.first?.name, "Test Project")
        XCTAssertEqual(mockClient.requestLog.count, 1)
    }
    
    func testNetworkError() async {
        // Arrange
        mockClient.setMockError(.noInternetConnection, for: .get, path: "/projects")
        
        // Act & Assert
        do {
            _ = try await service.fetchProjects()
            XCTFail("Expected error")
        } catch let error as APIError {
            XCTAssertEqual(error, .noInternetConnection)
        }
    }
}
```

### Future Enhancements

Planned improvements for the API client:

1. **Authentication Interceptor**
   - Automatic JWT token injection
   - Token refresh on 401
   - Retry after token refresh

2. **Request/Response Interceptors**
   - Custom header injection
   - Response transformation
   - Analytics tracking

3. **Advanced Caching**
   - HTTP cache support
   - Custom cache policies
   - Offline response serving

4. **Certificate Pinning**
   - SSL pinning for security
   - Trust validation
   - Certificate rotation

5. **Request Prioritization**
   - Priority queue for requests
   - Cancel low-priority on memory pressure
   - User-initiated vs background requests

### Integration Guidelines

**Creating New API Requests:**

1. Define response model:
```swift
struct ProjectResponse: Codable {
    let id: String
    let name: String
    let status: String
}
```

2. Create request:
```swift
struct FetchProjectRequest: APIRequest {
    typealias Response = ProjectResponse
    
    let projectId: String
    
    var path: String { "/projects/\(projectId)" }
    var method: HTTPMethod { .get }
}
```

3. Execute in service layer:
```swift
class ProjectService {
    private let apiClient: APIClientProtocol
    
    init(apiClient: APIClientProtocol = APIClient.shared) {
        self.apiClient = apiClient
    }
    
    func fetchProject(id: String) async throws -> ProjectResponse {
        let request = FetchProjectRequest(projectId: id)
        return try await apiClient.execute(request)
    }
}
```

4. Test with mock:
```swift
let mockClient = MockAPIClient()
mockClient.setMockResponse(expectedResponse, for: .get, path: "/projects/123")
let service = ProjectService(apiClient: mockClient)
```

---

**Best Practices:**
- Always use protocol (`APIClientProtocol`) for dependency injection
- Create dedicated request structs for each endpoint
- Use MockAPIClient for all unit tests
- Monitor logs in Console.app during development
- Handle specific APIError cases appropriately
- Set reasonable timeouts for requests
- Configure retry limits based on operation criticality
