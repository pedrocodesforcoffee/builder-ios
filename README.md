# Builder iOS - Construction Management Mobile App

Native iOS application for Bob the Builder construction management platform

## Tech Stack

- **Language:** Swift 5.9+
- **UI Framework:** UIKit with SwiftUI components
- **Architecture:** MVVM-C (Model-View-ViewModel-Coordinator)
- **Networking:** URLSession with Combine
- **Storage:** Core Data for offline, Keychain for secure data
- **Dependency Management:** CocoaPods / Swift Package Manager
- **CI/CD:** Fastlane

## Requirements

- **Xcode:** 15.0 or higher
- **iOS Deployment Target:** 15.0+
- **macOS:** 13.0+ (Ventura)
- **CocoaPods:** Latest version (or Swift Package Manager)

## Installation

### Clone Repository

```bash
git clone https://github.com/bobthebuilder/builder-ios.git
cd builder-ios
```

### Option 1: CocoaPods

```bash
# Install CocoaPods if not already installed
sudo gem install cocoapods

# Install dependencies
pod install

# Open workspace
open BobTheBuilder.xcworkspace
```

### Option 2: Swift Package Manager

```bash
# Open project in Xcode
open BobTheBuilder.xcodeproj

# Dependencies will be resolved automatically
```

### Automated Setup

Run the setup script:

```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

## Development Workflow

### Build and Run

1. Open `BobTheBuilder.xcworkspace` in Xcode
2. Select target device or simulator
3. Press `Cmd + R` to build and run

### Available Schemes

- **BobTheBuilder** - Main app target
- **BobTheBuilderTests** - Unit and integration tests
- **BobTheBuilderUITests** - UI tests

### Build Configurations

- **Development** - Debug build with dev API
- **Staging** - Release build with staging API
- **Production** - Release build with production API

## Project Structure

```
BobTheBuilder/
├── App/                    # Application lifecycle
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   └── Info.plist
├── Core/                   # Core functionality
│   ├── Network/            # Networking layer
│   ├── Storage/            # Data persistence
│   ├── Extensions/         # Swift extensions
│   └── Utilities/          # Helper utilities
├── Features/               # Feature modules
│   ├── Authentication/     # Login, signup
│   ├── Dashboard/          # Main dashboard
│   ├── Projects/           # Project management
│   ├── Resources/          # Resource tracking
│   └── Settings/           # App settings
├── Models/                 # Data models
│   ├── DTOs/               # Data transfer objects
│   └── CoreData/           # Core Data models
├── Services/               # Business services
│   ├── API/                # API clients
│   ├── Analytics/          # Analytics tracking
│   └── Push/               # Push notifications
├── UI/                     # UI components
│   ├── Components/         # Reusable components
│   ├── Screens/            # Screen views
│   ├── Themes/             # Design system
│   └── Storyboards/        # Interface Builder files
├── Resources/              # App resources
│   ├── Assets.xcassets/    # Images, colors
│   ├── Localizable.strings # Localization
│   └── LaunchScreen.storyboard
└── Config/                 # Build configurations
    ├── Development.xcconfig
    ├── Staging.xcconfig
    └── Production.xcconfig
```

## Testing

### Unit Tests

```bash
# Command line
xcodebuild test -workspace BobTheBuilder.xcworkspace \
  -scheme BobTheBuilder \
  -destination 'platform=iOS Simulator,name=iPhone 15'

# Or in Xcode: Cmd + U
```

### UI Tests

```bash
# Command line
xcodebuild test -workspace BobTheBuilder.xcworkspace \
  -scheme BobTheBuilder \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:BobTheBuilderUITests

# Or in Xcode: Select UI test target and Cmd + U
```

### Using Fastlane

```bash
fastlane test
```

## Code Signing

### Development

1. Open project in Xcode
2. Select target `BobTheBuilder`
3. Go to "Signing & Capabilities"
4. Select your development team
5. Enable "Automatically manage signing"

### Distribution

1. Ensure you have valid distribution certificates
2. Configure provisioning profiles in Xcode
3. Or use Fastlane Match for team certificate management

```bash
fastlane match development
fastlane match appstore
```

## Deployment

### TestFlight (Beta)

```bash
# Using Fastlane
fastlane beta

# Or manually in Xcode:
# Product > Archive > Distribute App > TestFlight
```

### App Store

```bash
# Using Fastlane
fastlane release

# Or manually in Xcode:
# Product > Archive > Distribute App > App Store Connect
```

## Environment Configuration

Environment-specific settings are in `BobTheBuilder/Config/`:

- `Development.xcconfig` - Local development
- `Staging.xcconfig` - Staging environment
- `Production.xcconfig` - Production environment

Update API URLs and other settings in these files.

## Documentation

- [Architecture Overview](./docs/ARCHITECTURE.md) - App architecture and design patterns
- [Project Overview](./docs/PROJECT_OVERVIEW.md) - Project goals and features
- [Contributing Guidelines](./docs/CONTRIBUTING.md) - How to contribute
- [Runbook](./docs/RUNBOOK.md) - Operations and deployment guide

## Key Features

- **Offline First:** Full offline support with Core Data
- **Real-time Sync:** Automatic data synchronization
- **Photo Capture:** In-app camera for project photos
- **GPS Tracking:** Location tracking for field workers
- **Push Notifications:** Real-time updates and alerts
- **Dark Mode:** System appearance support
- **Accessibility:** VoiceOver and Dynamic Type support

## Performance Targets

- Cold start: < 2 seconds
- View transitions: < 300ms
- API response handling: < 100ms
- Image loading: Progressive with caching
- Battery efficient background sync

## Minimum Supported Devices

- iPhone: iPhone 8 and newer
- iPad: iPad (5th generation) and newer
- iOS Version: 15.0+

## Contributing

Please read [CONTRIBUTING.md](./docs/CONTRIBUTING.md) for details on our code of conduct and development process.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and questions:
- GitHub Issues: https://github.com/bobthebuilder/builder-ios/issues
- Team Slack: #builder-ios channel
- Email: ios@bobthebuilder.com
