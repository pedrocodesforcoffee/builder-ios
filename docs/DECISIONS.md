# Architecture Decision Records (ADRs)

This document tracks key architectural and technical decisions made during the development of Builder iOS.

## Format

Each ADR follows this structure:
- **Status**: Proposed | Accepted | Deprecated | Superseded
- **Context**: The circumstances and constraints
- **Decision**: What was decided
- **Consequences**: Trade-offs and implications

---

## ADR-001: Native iOS Over Cross-Platform

**Date**: 2024-11-06
**Status**: Accepted

### Context
Need to decide between native iOS development vs cross-platform solutions (React Native, Flutter, etc.). Key considerations:
- Performance requirements (offline-first, photo handling)
- Platform features (camera, GPS, notifications)
- Developer expertise
- Time to market
- Maintenance burden

### Decision
Build native iOS application using Swift and UIKit/SwiftUI.

### Consequences

**Positive:**
- Full access to iOS platform features
- Best performance and user experience
- No bridge/wrapper overhead
- Direct access to new iOS features
- Better debugging tools (Xcode, Instruments)
- Native look and feel
- Smaller app size

**Negative:**
- Need separate codebase for Android
- iOS-specific skills required
- Cannot reuse web code
- Slower initial development (one platform at a time)

**Mitigations:**
- Share API client logic where possible
- Document platform-specific implementations
- Consider code sharing strategies for business logic
- Prioritize iOS first, then Android

---

## ADR-002: MVVM-C Architecture Pattern

**Date**: 2024-11-06
**Status**: Accepted

### Context
Need to choose an architecture pattern that provides:
- Testability
- Separation of concerns
- Scalability
- Clear navigation management
- Team familiarity

Options considered: MVC, MVP, MVVM, VIPER, Clean Architecture

### Decision
Implement MVVM-C (Model-View-ViewModel-Coordinator) pattern.

### Consequences

**Positive:**
- Clear separation of concerns
- Highly testable (ViewModels independent of UI)
- Coordinators manage navigation flow
- Reactive data binding with Combine
- Scalable for large apps
- Easier to reason about data flow

**Negative:**
- More files and boilerplate
- Steeper learning curve vs MVC
- Potential over-engineering for simple screens

**Mitigations:**
- Provide templates for common patterns
- Document architecture in detail
- Allow flexibility for trivial screens
- Create reusable coordinator base classes

---

## ADR-003: UIKit Primary, SwiftUI Secondary

**Date**: 2024-11-06
**Status**: Accepted

### Context
SwiftUI is the future of iOS development, but UIKit is more mature and stable. Need to decide which to prioritize for:
- Main navigation and complex screens
- Simple views and components
- Custom animations
- Third-party library compatibility

### Decision
Use UIKit as the primary framework with SwiftUI for appropriate use cases:
- UIKit for: ViewControllers, navigation, complex layouts, table/collection views
- SwiftUI for: Simple views, settings screens, previews, new components

### Consequences

**Positive:**
- UIKit stability and maturity
- Better third-party library support
- More control over layout and performance
- Team expertise with UIKit
- SwiftUI for modern, declarative views
- Gradual migration path to SwiftUI

**Negative:**
- Maintaining two UI paradigms
- Context switching between frameworks
- SwiftUI interop can be complex
- May miss some SwiftUI benefits

**Mitigations:**
- Clear guidelines on when to use each
- UIHostingController for SwiftUI in UIKit
- Minimize framework mixing in single views
- Evaluate SwiftUI for new features

---

## ADR-004: Core Data for Offline Storage

**Date**: 2024-11-06
**Status**: Accepted

### Context
App requires robust offline support with:
- Local data persistence
- Complex relationships
- Migration support
- Performance for large datasets
- Sync with backend

Options considered: Core Data, Realm, SQLite, UserDefaults

### Decision
Use Core Data for primary offline storage.

### Consequences

**Positive:**
- Native iOS solution, no third-party dependencies
- Excellent performance
- Automatic relationship management
- Migration support
- iCloud sync support (if needed later)
- NSFetchedResultsController for table views
- Powerful querying with NSPredicate

**Negative:**
- Steeper learning curve
- Verbose syntax
- Thread safety requires care
- Debugging can be challenging

**Mitigations:**
- Use Repository pattern to abstract Core Data
- Leverage background contexts for heavy operations
- Implement proper error handling
- Use Core Data extensions for cleaner code

---

## ADR-005: Combine for Reactive Programming

**Date**: 2024-11-06
**Status**: Accepted

### Context
Need reactive programming framework for:
- Binding ViewModels to Views
- Handling async operations
- Stream-based data flow
- Chaining operations

Options considered: Combine, RxSwift, custom closures

### Decision
Use Apple's Combine framework for reactive programming.

### Consequences

**Positive:**
- Native Apple framework
- Tight integration with Swift and SwiftUI
- Type-safe operators
- Memory management with AnyCancellable
- No third-party dependencies
- Future-proof (Apple's direction)

**Negative:**
- iOS 13+ only (not an issue for iOS 15+ target)
- Smaller community vs RxSwift
- Less documentation and resources
- Learning curve for team

**Mitigations:**
- Provide Combine training for team
- Document common patterns
- Create helper extensions
- Use async/await where simpler

---

## ADR-006: URLSession with Combine for Networking

**Date**: 2024-11-06
**Status**: Accepted

### Context
Need networking solution that:
- Integrates with Combine
- Supports authentication
- Handles errors gracefully
- Provides request/response interceptors

Options considered: Alamofire, Moya, URLSession

### Decision
Use native URLSession with Combine publishers, wrapped in a custom API service layer.

### Consequences

**Positive:**
- No third-party dependencies
- Full control over implementation
- Native integration with Combine
- Better performance
- Easier to debug
- Certificate pinning support

**Negative:**
- More boilerplate code
- Need to implement common features manually
- Missing convenience methods from Alamofire

**Mitigations:**
- Create reusable networking layer
- Implement common features (retry, interceptors)
- Document networking patterns
- Can add Alamofire later if needed

---

## ADR-007: Swift Package Manager Over CocoaPods

**Date**: 2024-11-06
**Status**: Accepted

### Context
Need dependency management for third-party libraries. Options:
- CocoaPods (mature, widely used)
- Swift Package Manager (native, modern)
- Carthage (decentralized)

### Decision
Prefer Swift Package Manager (SPM) with CocoaPods as fallback for libraries not available via SPM.

### Consequences

**Positive:**
- Native Xcode integration
- Faster dependency resolution
- No workspace files
- Better Git handling
- Apple's official solution
- Cleaner project structure

**Negative:**
- Some libraries not available on SPM
- Less mature than CocoaPods
- Binary dependencies can be tricky

**Mitigations:**
- Use CocoaPods for unavailable packages
- Check SPM support before adding dependencies
- Document dependency choices

---

## ADR-008: Protocol-Oriented Programming

**Date**: 2024-11-06
**Status**: Accepted

### Context
Swift encourages protocol-oriented programming. Need to decide how heavily to use protocols for:
- Dependency injection
- Testability
- Abstraction

### Decision
Use protocol-oriented programming extensively:
- Protocols for all services
- Dependency injection via protocols
- Mock implementations for testing

### Consequences

**Positive:**
- Highly testable code
- Flexible architecture
- Easy to mock dependencies
- Clear contracts between components
- Supports TDD

**Negative:**
- More files and boilerplate
- Can be over-engineered for simple cases
- Increased abstraction complexity

**Mitigations:**
- Use protocols judiciously
- Document protocol purposes
- Create protocol templates
- Allow concrete implementations for simple cases

---

## ADR-009: Manual Dependency Injection

**Date**: 2024-11-06
**Status**: Accepted

### Context
Need dependency injection strategy. Options:
- Manual DI
- Swinject
- Needle
- Factory pattern

### Decision
Use manual dependency injection with a ServiceContainer for managing dependencies.

### Consequences

**Positive:**
- No third-party framework
- Full control and transparency
- Easier to debug
- No magic or reflection
- Simple to understand
- Compile-time safety

**Negative:**
- More manual wiring code
- Can be verbose
- Need to maintain container manually

**Mitigations:**
- Create ServiceContainer for centralized management
- Document DI patterns
- Use property injection where appropriate
- Consider DI framework if complexity grows

---

## ADR-010: Fastlane for CI/CD

**Date**: 2024-11-06
**Status**: Accepted

### Context
Need automated build and deployment pipeline for:
- Running tests
- Building app
- Code signing
- TestFlight deployment
- App Store submission

### Decision
Use Fastlane for all CI/CD automation.

### Consequences

**Positive:**
- Industry standard for iOS
- Handles code signing complexity
- Automates screenshots
- Beta deployment to TestFlight
- App Store submission
- Extensive documentation
- Strong community

**Negative:**
- Ruby dependency
- Learning curve for configuration
- Requires maintenance of Fastfile

**Mitigations:**
- Document Fastlane setup
- Version control Fastlane configuration
- Keep lanes simple and focused
- Use Match for code signing

---

## ADR-011: SwiftLint for Code Quality

**Date**: 2024-11-06
**Status**: Accepted

### Context
Need to enforce code style and quality standards across the team.

### Decision
Use SwiftLint with custom rules for the project.

### Consequences

**Positive:**
- Consistent code style
- Catches common errors
- Integrates with Xcode
- Configurable rules
- Fast execution
- Supports custom rules

**Negative:**
- Can be overly strict
- Some rules may be controversial
- Requires team buy-in

**Mitigations:**
- Start with recommended rules
- Customize gradually based on team feedback
- Document rule rationale
- Allow disabling rules with justification

---

## ADR-012: Keychain for Secure Storage

**Date**: 2024-11-06
**Status**: Accepted

### Context
Need secure storage for:
- Authentication tokens
- User credentials
- Sensitive user data

Options: UserDefaults (insecure), Keychain, custom encryption

### Decision
Use iOS Keychain for all sensitive data storage.

### Consequences

**Positive:**
- Hardware-backed encryption
- OS-level security
- Biometric access control
- Persists across app reinstalls (optional)
- No manual encryption needed

**Negative:**
- Complex API
- Synchronization edge cases
- Debugging can be difficult

**Mitigations:**
- Create Keychain wrapper class
- Abstract complexity behind simple API
- Document Keychain usage patterns
- Test on real devices

---

## ADR-013: Offline-First Architecture

**Date**: 2024-11-06
**Status**: Accepted

### Context
Construction sites often have poor connectivity. App must work fully offline with:
- Local data storage
- Background sync when online
- Conflict resolution
- Queued operations

### Decision
Implement offline-first architecture:
1. Always read from local Core Data
2. Display data immediately
3. Sync with backend in background
4. Queue mutations when offline
5. Handle conflicts on sync

### Consequences

**Positive:**
- Works without internet
- Fast user experience
- Resilient to network issues
- Better battery life (fewer network calls)
- Users can be productive anywhere

**Negative:**
- Complex sync logic
- Conflict resolution challenges
- Increased storage requirements
- Data consistency concerns
- More complex testing

**Mitigations:**
- Last-write-wins for simple conflicts
- User resolution for complex conflicts
- Clear sync status indicators
- Thorough testing of sync scenarios
- Background sync optimization

---

## ADR-014: Feature Flags for Gradual Rollout

**Date**: 2024-11-06
**Status**: Proposed

### Context
Need ability to:
- Enable/disable features remotely
- A/B test new features
- Gradual rollout to users
- Emergency kill switch

### Decision
Implement feature flag system using Firebase Remote Config (or similar).

### Consequences

**Positive:**
- Remote feature control
- A/B testing capability
- Gradual rollouts
- Quick disable if issues found
- No app update required

**Negative:**
- Additional complexity
- Potential for configuration drift
- Testing all flag combinations
- Dependency on remote service

**Mitigations:**
- Document all feature flags
- Default to safe fallback values
- Clean up old flags regularly
- Test with flags on and off

---

## Template for Future ADRs

```markdown
## ADR-XXX: [Title]

**Date**: YYYY-MM-DD
**Status**: Proposed | Accepted | Deprecated | Superseded

### Context
[Describe the problem, constraints, and options considered]

### Decision
[Describe what was decided and why]

### Consequences

**Positive:**
- [List benefits and advantages]

**Negative:**
- [List drawbacks and limitations]

**Mitigations:**
- [How to address negative consequences]
```
