# Bob the Builder iOS App

Native iOS application for Bob the Builder construction management platform, built with SwiftUI.

## Requirements

- **Xcode:** 14.0 or higher
- **iOS Deployment Target:** 15.0+
- **Swift:** 5.5+
- **macOS:** 13.0+ (Ventura) recommended

## Project Setup

### 1. Clone Repository

```bash
git clone https://github.com/bobthebuilder/builder-ios.git
cd builder-ios
```

### 2. Generate Xcode Project

This project uses XcodeGen to generate the Xcode project file. This ensures consistent project configuration across the team.

#### Install XcodeGen (if not already installed)

```bash
brew install xcodegen
```

#### Generate the project

```bash
xcodegen generate
```

This will create `BobTheBuilder.xcodeproj` from the `project.yml` configuration file.

### 3. Open Project

```bash
open BobTheBuilder.xcodeproj
```

### 4. Configure Signing

1. Select the `BobTheBuilder` target in Xcode
2. Go to "Signing & Capabilities" tab
3. Select your development team
4. Ensure "Automatically manage signing" is enabled

### 5. Build and Run

Press `⌘+R` to build and run the app in the simulator.

## Project Structure

```
BobTheBuilder/
├── App/                         # Application entry point
│   ├── BobTheBuilderApp.swift   # SwiftUI App lifecycle
│   ├── Info.plist               # App configuration
│   └── BobTheBuilder.entitlements
├── ContentView.swift            # Main content view
├── Core/                        # Core functionality
│   ├── Configuration/           # App configuration
│   ├── Networking/              # Network layer
│   └── Utilities/               # Helper utilities
├── Features/                    # Feature modules
│   ├── Authentication/          # Login, signup
│   ├── Projects/                # Project management
│   ├── RFI/                     # RFI management
│   └── Settings/                # App settings
├── Resources/                   # App resources
│   ├── Assets.xcassets/         # Images, colors, icons
│   └── Localizable.strings      # Localization strings
├── Shared/                      # Shared components
│   ├── Components/              # Reusable UI components
│   ├── Extensions/              # Swift extensions
│   └── Models/                  # Data models
└── Config/                      # Build configurations
    ├── Development.xcconfig
    ├── Staging.xcconfig
    └── Production.xcconfig
```

## Tech Stack

- **Language:** Swift 5.5+
- **UI Framework:** SwiftUI
- **Architecture:** MVVM (Model-View-ViewModel)
- **Networking:** URLSession with async/await
- **Storage:** UserDefaults for settings, Keychain for secure data
- **Dependency Management:** Swift Package Manager
- **CI/CD:** Fastlane
- **Project Generation:** XcodeGen

## Bundle Identifier

- **Production:** `com.bobthebuilder.app`
- **App Group:** `group.com.bobthebuilder.app`

## Build Configurations

The project supports three build configurations:

- **Debug (Development)** - Debug build with development API endpoints
- **Staging** - Release build with staging API endpoints
- **Release (Production)** - Release build with production API endpoints

Configuration is managed through `.xcconfig` files in the `BobTheBuilder/Config/` directory.

## Testing

### Run Unit Tests

```bash
# Command line
xcodebuild test -project BobTheBuilder.xcodeproj \
  -scheme BobTheBuilder \
  -destination 'platform=iOS Simulator,name=iPhone 15'

# Or in Xcode: ⌘+U
```

### Run UI Tests

```bash
# Command line
xcodebuild test -project BobTheBuilder.xcodeproj \
  -scheme BobTheBuilder \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:BobTheBuilderUITests

# Or in Xcode: Select UI test target and ⌘+U
```

### Using Fastlane

```bash
fastlane test
```

## Development Workflow

### Adding New Files

When adding new files or folders to the project:

1. Create the files in the appropriate directory
2. Run `xcodegen generate` to update the Xcode project
3. The project file will automatically include the new files

**Note:** Do not manually modify `BobTheBuilder.xcodeproj` - all changes should be made in `project.yml` and regenerated.

### Code Quality

The project includes a SwiftLint build phase to enforce code style. Install SwiftLint:

```bash
brew install swiftlint
```

If SwiftLint is not installed, the build will show a warning but will not fail.

## Capabilities

The following capabilities are configured:

- **App Groups:** `group.com.bobthebuilder.app` - For sharing data between app and extensions (future widgets, etc.)

## Key Features (Planned)

- **Offline First:** Full offline support
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

## Minimum Supported Devices

- **iPhone:** iPhone 8 and newer
- **iPad:** iPad (5th generation) and newer
- **iOS Version:** 15.0+

## Code Signing

### Development

1. Open project in Xcode
2. Select target `BobTheBuilder`
3. Go to "Signing & Capabilities"
4. Select your development team
5. Enable "Automatically manage signing"

### Distribution

Distribution will be managed through Fastlane and CI/CD pipelines.

## Deployment

### TestFlight (Beta)

```bash
# Using Fastlane
fastlane beta
```

### App Store

```bash
# Using Fastlane
fastlane release
```

## Documentation

- [Architecture Overview](./docs/ARCHITECTURE.md) - App architecture and design patterns
- [Project Overview](./docs/PROJECT_OVERVIEW.md) - Project goals and features
- [Contributing Guidelines](./docs/CONTRIBUTING.md) - How to contribute
- [Runbook](./docs/RUNBOOK.md) - Operations and deployment guide

## Troubleshooting

### "No such file or directory" errors

If you get build errors about missing files, regenerate the project:

```bash
xcodegen generate
```

### Code signing issues

Ensure you have selected a valid development team in "Signing & Capabilities" for each target.

### SwiftLint warnings

Install SwiftLint to see code style warnings:

```bash
brew install swiftlint
```

## Contributing

Please read [CONTRIBUTING.md](./docs/CONTRIBUTING.md) for details on our code of conduct and development process.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and questions:
- GitHub Issues: https://github.com/bobthebuilder/builder-ios/issues
- Team Slack: #builder-ios channel
- Email: ios@bobthebuilder.com

---

**Current Version:** 0.1.0 (Build 1)
**Last Updated:** 2024
