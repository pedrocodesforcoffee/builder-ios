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
