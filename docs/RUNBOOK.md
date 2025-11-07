# Runbook - Builder iOS Operations Guide

## Development Setup

### Prerequisites Checklist

- [ ] macOS 13.0+ (Ventura or later)
- [ ] Xcode 15.0+ installed from App Store
- [ ] Command Line Tools installed
- [ ] CocoaPods or use Swift Package Manager
- [ ] Fastlane (optional but recommended)
- [ ] Apple Developer account access

### Initial Setup

1. **Install Xcode Command Line Tools**
```bash
xcode-select --install
```

2. **Install CocoaPods** (if using CocoaPods)
```bash
sudo gem install cocoapods
```

3. **Clone Repository**
```bash
git clone https://github.com/bobthebuilder/builder-ios.git
cd builder-ios
```

4. **Install Dependencies**
```bash
# If using CocoaPods
pod install

# If using SPM, dependencies resolve automatically in Xcode
```

5. **Open Workspace**
```bash
# If using CocoaPods
open BobTheBuilder.xcworkspace

# If using SPM only
open BobTheBuilder.xcodeproj
```

6. **Configure Code Signing**
- In Xcode, select the project
- Go to "Signing & Capabilities"
- Select your development team
- Enable "Automatically manage signing"

---

## Build Configurations

The app supports three environments with dedicated Xcode schemes:

### Development (BobTheBuilder-Dev)
- **Bundle ID:** com.bobthebuilder.app.dev
- **API:** https://api-dev.bobthebuilder.com
- **Purpose:** Local development and debugging
- **Certificate:** Development
- **App Name:** Bob Dev
- **Environment Badge:** Orange "DEV" badge
- **Configurations:** Debug-Dev, Release-Dev

### Staging (BobTheBuilder-Stage)
- **Bundle ID:** com.bobthebuilder.app.staging
- **API:** https://api-stage.bobthebuilder.com
- **Purpose:** Internal testing and QA
- **Certificate:** Distribution (Ad Hoc or TestFlight)
- **App Name:** Bob Staging
- **Environment Badge:** Blue "STAGE" badge
- **Configurations:** Debug-Stage, Release-Stage

### Production (BobTheBuilder-Prod)
- **Bundle ID:** com.bobthebuilder.app
- **API:** https://api.bobthebuilder.com
- **Purpose:** App Store release
- **Certificate:** Distribution (App Store)
- **App Name:** Bob the Builder
- **Environment Badge:** None (clean UI)
- **Configurations:** Debug-Prod, Release-Prod

### Switching Environments

In Xcode, click the scheme selector (next to device selector) and choose:
- **BobTheBuilder-Dev** for development
- **BobTheBuilder-Stage** for staging
- **BobTheBuilder-Prod** for production

### Environment Indicators

Non-production builds display a colored badge:
- Dev: Orange "DEV" badge at top of screen
- Stage: Blue "STAGE" badge at top of screen
- Prod: No badge (clean production UI)

The main screen also displays:
- Current environment name
- API base URL
- App version and build number
- Debug build indicator

### Configuration Files

Environment settings are in `.xcconfig` files:
- `BobTheBuilder/Config/Development.xcconfig`
- `BobTheBuilder/Config/Staging.xcconfig`
- `BobTheBuilder/Config/Production.xcconfig`

To modify environment settings, edit these files and regenerate:
```bash
xcodegen generate
```

---

## Running the App

### From Xcode

1. **Select Scheme**
   - Product > Scheme > BobTheBuilder

2. **Select Destination**
   - Choose simulator or connected device
   - Recommended: iPhone 15 simulator

3. **Build and Run**
   - Press `Cmd + R` or click Run button

### From Command Line

```bash
# Build
xcodebuild -workspace BobTheBuilder.xcworkspace \
  -scheme BobTheBuilder \
  -configuration Debug \
  build

# Run on simulator
xcrun simctl boot "iPhone 15"
xcodebuild -workspace BobTheBuilder.xcworkspace \
  -scheme BobTheBuilder \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  build
```

---

## Testing

### Unit Tests

**In Xcode:**
```
Cmd + U
```

**Command Line:**
```bash
xcodebuild test \
  -workspace BobTheBuilder.xcworkspace \
  -scheme BobTheBuilder \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

**Fastlane:**
```bash
fastlane test
```

### UI Tests

**In Xcode:**
- Select BobTheBuilderUITests scheme
- Press `Cmd + U`

**Command Line:**
```bash
xcodebuild test \
  -workspace BobTheBuilder.xcworkspace \
  -scheme BobTheBuilder \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:BobTheBuilderUITests
```

### Code Coverage

1. Edit Scheme > Test
2. Check "Code Coverage"
3. Run tests
4. View coverage in Report Navigator

---

## Code Signing & Certificates

### Development Certificates

1. **Automatic Signing** (Recommended for development)
   - Xcode > Project > Signing & Capabilities
   - Enable "Automatically manage signing"
   - Select team

2. **Manual Signing**
   - Download certificates from Apple Developer portal
   - Install in Keychain
   - Download provisioning profiles
   - Select in Xcode build settings

### Using Fastlane Match

```bash
# Set up match
fastlane match init

# Get development certificates
fastlane match development

# Get distribution certificates
fastlane match appstore
```

---

## Deployment

### TestFlight Deployment

#### Prerequisites
- [ ] App Store Connect access
- [ ] Distribution certificate
- [ ] App Store provisioning profile
- [ ] Increment build number

#### Manual Process

1. **Archive Build**
   - Product > Archive
   - Wait for archive to complete

2. **Upload to TestFlight**
   - Window > Organizer
   - Select archive
   - Click "Distribute App"
   - Choose "App Store Connect"
   - Select options and upload

3. **Submit for Review** (if needed)
   - Go to App Store Connect
   - Select build
   - Submit for external testing review

#### Using Fastlane

```bash
# Build and upload to TestFlight
fastlane beta
```

### App Store Deployment

#### Prerequisites
- [ ] All TestFlight testing complete
- [ ] App Store screenshots prepared
- [ ] App Store description updated
- [ ] Privacy policy URL
- [ ] Support URL

#### Process

1. **Create App Store Version**
   - App Store Connect > My Apps
   - Click "+" to add version
   - Fill in What's New

2. **Upload Build**
```bash
fastlane release
```

3. **Configure Release**
   - Add screenshots
   - Set pricing
   - Configure availability
   - Submit for review

4. **Monitor Review Status**
   - Check App Store Connect daily
   - Respond to any reviewer questions

---

## Common Issues

### Build Failures

#### "No such module" Error
```bash
# Clean build folder
Cmd + Shift + K

# Clean derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/

# Re-install pods (if using CocoaPods)
pod deintegrate
pod install
```

#### Code Signing Error
- Verify team is selected in Xcode
- Check certificate is valid and not expired
- Ensure provisioning profile matches bundle ID
- Try "Automatically manage signing"

#### Build Time Too Long
- Check for circular dependencies
- Optimize Swift compilation flags
- Use Objective-C bridging header judiciously
- Enable whole module optimization for release builds

### Runtime Issues

#### App Crashes on Launch
1. Check crash logs in Xcode > Window > Devices and Simulators
2. Look for exceptions in console output
3. Verify Info.plist is correctly configured
4. Check for missing resources

#### Networking Not Working
1. Verify API URL in .xcconfig file
2. Check Info.plist for ATS exceptions if needed
3. Test API endpoint with curl
4. Check network connectivity in simulator

#### Core Data Issues
```bash
# Reset simulator
xcrun simctl erase all

# Or in Simulator app: Device > Erase All Content and Settings
```

### Certificate/Provisioning Issues

#### Expired Certificate
1. Go to Apple Developer portal
2. Revoke old certificate
3. Create new certificate
4. Download and install
5. Update provisioning profiles

#### Profile Mismatch
- Ensure bundle ID matches exactly
- Check capabilities match (e.g., Push Notifications)
- Regenerate provisioning profile if needed

---

## Performance Monitoring

### Instruments

```bash
# Profile for time
instruments -t "Time Profiler" -D trace.trace \
  path/to/BobTheBuilder.app

# Profile for allocations
instruments -t "Allocations" -D trace.trace \
  path/to/BobTheBuilder.app
```

### Memory Leaks

1. Product > Profile (Cmd + I)
2. Select "Leaks" template
3. Run app and exercise features
4. Watch for leak indicators

### Energy Usage

1. Product > Profile
2. Select "Energy Log"
3. Test typical user scenarios
4. Review energy impact report

---

## Monitoring & Analytics

### Crash Reporting

**Firebase Crashlytics:**
```swift
// In AppDelegate
import FirebaseCrashlytics

Crashlytics.crashlytics().log("App started")
```

**View Crashes:**
- Firebase Console > Crashlytics
- Filter by version
- Review stack traces

### Analytics

**Firebase Analytics:**
```swift
Analytics.logEvent("project_created", parameters: [
    "project_id": projectId,
    "project_type": projectType
])
```

**App Store Connect Analytics:**
- App Store Connect > Analytics
- View impressions, downloads, crashes
- Track retention and engagement

---

## Release Checklist

### Pre-Release

- [ ] All tests passing
- [ ] No compiler warnings
- [ ] Code reviewed and approved
- [ ] Version number incremented
- [ ] Build number incremented
- [ ] Localizations updated
- [ ] API configured for production
- [ ] Analytics tracking verified
- [ ] Crash reporting enabled

### TestFlight

- [ ] Build uploaded
- [ ] Internal testing complete
- [ ] External testing initiated
- [ ] Feedback reviewed and addressed
- [ ] No critical issues reported

### App Store Submission

- [ ] Screenshots updated (all required sizes)
- [ ] App description updated
- [ ] Keywords optimized
- [ ] Privacy policy current
- [ ] Support URL working
- [ ] Age rating accurate
- [ ] Submitted for review

### Post-Release

- [ ] Monitor crash reports
- [ ] Watch user reviews
- [ ] Track analytics metrics
- [ ] Respond to support requests
- [ ] Plan next iteration

---

## Useful Commands

### Xcode

```bash
# List simulators
xcrun simctl list devices

# Boot simulator
xcrun simctl boot "iPhone 15"

# Take screenshot
xcrun simctl io booted screenshot screenshot.png

# Record video
xcrun simctl io booted recordVideo video.mov

# Clear console
Cmd + K (in Xcode console)

# Jump to definition
Cmd + Click or Cmd + Control + J
```

### CocoaPods

```bash
# Update pods
pod update

# Install specific version
pod 'Alamofire', '5.8.0'

# Check outdated
pod outdated

# Repo update
pod repo update
```

### Fastlane

```bash
# List lanes
fastlane lanes

# Update fastlane
bundle update fastlane

# Generate screenshots
fastlane snapshot
```

---

## Emergency Procedures

### Critical Bug in Production

1. **Assess Severity**
   - Is app unusable?
   - Does it affect all users?
   - Is data at risk?

2. **Quick Fix**
   - Create hotfix branch
   - Implement minimal fix
   - Test thoroughly
   - Fast-track review (contact Apple if critical)

3. **Expedited Review Request**
   - App Store Connect > Version > Request Expedited Review
   - Provide clear explanation

### App Rejected

1. **Read Rejection Reason** carefully
2. **Address All Issues** mentioned
3. **Update App** as needed
4. **Respond in Resolution Center**
5. **Resubmit**

### Certificate Expiration

1. **Renew Certificate** immediately
2. **Update Provisioning Profiles**
3. **Rebuild and Test**
4. **Upload new build** if needed

---

## Resources

- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Fastlane Documentation](https://docs.fastlane.tools/)
- [Swift Style Guide](https://swift.org/documentation/api-design-guidelines/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
