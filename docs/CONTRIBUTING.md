# Contributing to Builder iOS

Thank you for your interest in contributing to Builder iOS!

## Code of Conduct

Be respectful, constructive, and collaborative. We're all here to build great software.

## Development Workflow

### Getting Started

1. **Fork and Clone**
```bash
git clone https://github.com/your-username/builder-ios.git
cd builder-ios
pod install  # or use SPM
open BobTheBuilder.xcworkspace
```

2. **Create Feature Branch**
```bash
git checkout -b feature/your-feature-name
```

3. **Make Changes**
- Follow Swift style guide
- Add tests for new features
- Update documentation

4. **Test**
```bash
# Run tests
Cmd + U in Xcode

# Or
fastlane test
```

5. **Commit**
```bash
git commit -m "feat: add your feature description"
```

6. **Push and Create PR**
```bash
git push origin feature/your-feature-name
```

## Swift Style Guide

### Naming Conventions

```swift
// Types: PascalCase
class ProjectViewModel { }
struct Project { }
enum ProjectStatus { }

// Variables and functions: camelCase
var projectName: String
func fetchProjects() { }

// Constants: camelCase
let maxProjectCount = 100
let apiTimeout: TimeInterval = 30.0

// Private properties: underscore prefix optional
private var _cachedData: [Project]?
private let networkService: NetworkService
```

### Code Organization

```swift
// MARK: - Type Definition
class ProjectViewController: UIViewController {

    // MARK: - Properties

    // Public properties first
    var project: Project?

    // Private properties
    private let viewModel: ProjectViewModel
    private let tableView = UITableView()

    // MARK: - Initialization

    init(viewModel: ProjectViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    // MARK: - Setup

    private func setupUI() {
        // UI setup code
    }

    // MARK: - Actions

    @objc private func refreshButtonTapped() {
        // Action code
    }

    // MARK: - Private Methods

    private func updateUI() {
        // Update logic
    }
}
```

### Swift Conventions

```swift
// Good: Use guard for early returns
func process(project: Project?) {
    guard let project = project else {
        return
    }
    // Continue with unwrapped project
}

// Good: Use map/filter/reduce
let activeProjects = projects.filter { $0.isActive }
let projectNames = projects.map { $0.name }

// Good: Use trailing closures
fetchProjects { projects in
    self.display(projects)
}

// Good: Explicit self in closures
apiService.fetch { [weak self] result in
    self?.handleResult(result)
}

// Avoid: Force unwrapping
let name = project!.name  // Bad
let name = project?.name ?? "Unknown"  // Good

// Avoid: Implicitly unwrapped optionals (unless necessary)
var name: String!  // Avoid if possible
var name: String?  // Prefer
```

## Architecture Guidelines

### MVVM-C Pattern

**ViewController (View)**
- Displays UI
- Handles user interaction
- No business logic

**ViewModel**
- Business logic
- Data transformation
- Publishes updates via Combine

**Coordinator**
- Navigation
- Screen flow
- Dependency injection

**Example:**
```swift
// View
class ProjectListViewController: UIViewController {
    private let viewModel: ProjectListViewModel

    private func bindViewModel() {
        viewModel.$projects
            .receive(on: DispatchQueue.main)
            .sink { [weak self] projects in
                self?.updateUI(with: projects)
            }
            .store(in: &cancellables)
    }
}

// ViewModel
class ProjectListViewModel: ObservableObject {
    @Published private(set) var projects: [Project] = []

    func fetchProjects() {
        // Fetch logic
    }
}

// Coordinator
class ProjectCoordinator {
    func start() {
        let viewModel = ProjectListViewModel(apiService: services.api)
        let viewController = ProjectListViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}
```

## Testing Requirements

### Unit Tests

Minimum 70% code coverage for business logic.

```swift
class ProjectViewModelTests: XCTestCase {
    var sut: ProjectListViewModel!
    var mockAPIService: MockAPIService!

    override func setUp() {
        super.setUp()
        mockAPIService = MockAPIService()
        sut = ProjectListViewModel(apiService: mockAPIService)
    }

    override func tearDown() {
        sut = nil
        mockAPIService = nil
        super.tearDown()
    }

    func testFetchProjectsSuccess() {
        // Given
        let expectedProjects = [Project.mock()]
        mockAPIService.projectsToReturn = expectedProjects

        // When
        let expectation = self.expectation(description: "Projects fetched")
        sut.$projects
            .dropFirst()
            .sink { projects in
                // Then
                XCTAssertEqual(projects.count, 1)
                XCTAssertEqual(projects, expectedProjects)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        sut.fetchProjects()
        wait(for: [expectation], timeout: 1.0)
    }
}
```

### UI Tests

Test critical user flows.

```swift
class ProjectFlowUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launch()
    }

    func testCreateProjectFlow() {
        // Tap new project button
        app.buttons["newProjectButton"].tap()

        // Fill form
        let nameField = app.textFields["projectNameField"]
        nameField.tap()
        nameField.typeText("Test Project")

        // Submit
        app.buttons["createButton"].tap()

        // Verify
        XCTAssertTrue(app.staticTexts["Test Project"].waitForExistence(timeout: 2))
    }
}
```

## Accessibility

All UI must be accessible:

```swift
// Label buttons
button.accessibilityLabel = "Create Project"

// Add hints
button.accessibilityHint = "Creates a new construction project"

// Mark as button
view.accessibilityTraits = .button

// Group elements
view.isAccessibilityElement = true
view.accessibilityLabel = "Project: \(name)"

// Support Dynamic Type
label.font = UIFont.preferredFont(forTextStyle: .body)
label.adjustsFontForContentSizeCategory = true
```

## Commit Message Format

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Code style (formatting)
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance

**Examples:**
```
feat(projects): add offline sync support

Implement Core Data caching for projects with background sync
when network becomes available.

Closes #123
```

```
fix(auth): resolve token refresh issue

Token was not refreshing correctly causing users to be logged out.
Now properly refreshes token before expiration.

Fixes #456
```

## Pull Request Process

### Before Submitting

- [ ] All tests passing
- [ ] No warnings
- [ ] Code formatted
- [ ] Documentation updated
- [ ] Accessibility verified
- [ ] No force unwrapping (unless justified)

### PR Description

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
How the changes were tested

## Screenshots
Before/after screenshots for UI changes

## Checklist
- [ ] Tests pass
- [ ] No warnings
- [ ] Accessibility verified
- [ ] Code reviewed

## Related Issues
Closes #123
```

### Review Process

1. Automated checks (CI/CD)
2. Code review from 1+ team members
3. All feedback addressed
4. Approved by maintainer
5. Squash and merge

## Code Review Checklist

**For Reviewers:**

- [ ] Code follows style guide
- [ ] Logic is clear and correct
- [ ] Tests are adequate
- [ ] No obvious bugs
- [ ] Performance considerations addressed
- [ ] Accessibility implemented
- [ ] Memory management correct (no retain cycles)
- [ ] Error handling appropriate
- [ ] Comments explain complex logic

## Project Organization

### File Structure

```
BobTheBuilder/
├── App/                     # App lifecycle
├── Features/
│   └── Projects/
│       ├── Views/          # ViewControllers
│       ├── ViewModels/     # ViewModels
│       ├── Coordinators/   # Coordinators
│       └── Models/         # Feature models
├── Core/
│   ├── Network/            # API layer
│   ├── Storage/            # Data persistence
│   └── Extensions/         # Extensions
└── Resources/              # Assets, strings
```

### Adding New Features

1. Create feature directory in `Features/`
2. Add View, ViewModel, Coordinator
3. Register coordinator in AppCoordinator
4. Add tests
5. Update documentation

## Performance Guidelines

- Use `lazy` for expensive computations
- Avoid retain cycles with `[weak self]`
- Profile with Instruments before optimizing
- Cache images appropriately
- Use background queues for heavy work
- Optimize list performance (cell reuse, prefetching)

## SwiftLint

We use SwiftLint to enforce style:

```yaml
# .swiftlint.yml
disabled_rules:
  - trailing_whitespace
opt_in_rules:
  - empty_count
  - empty_string
line_length: 120
```

Run SwiftLint:
```bash
swiftlint
swiftlint --fix  # Auto-fix issues
```

## Getting Help

- **Questions:** Open GitHub Discussion
- **Bug Reports:** Create GitHub Issue
- **Feature Requests:** Create GitHub Issue with [Feature] tag
- **Security:** Email security@bobthebuilder.com
- **Slack:** #builder-ios channel

Thank you for contributing!
