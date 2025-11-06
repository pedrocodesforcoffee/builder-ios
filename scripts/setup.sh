#!/bin/bash
# iOS Project Setup Script for Bob the Builder

set -e  # Exit on error

echo "🔨 Setting up Bob the Builder iOS project..."
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Check for Xcode
echo "Checking for Xcode..."
if ! command -v xcodebuild &> /dev/null; then
    print_error "Xcode is not installed. Please install Xcode from the App Store."
    exit 1
fi
print_success "Xcode found: $(xcodebuild -version | head -n 1)"

# Check Xcode version
XCODE_VERSION=$(xcodebuild -version | grep -o "Xcode [0-9]*" | grep -o "[0-9]*")
if [ "$XCODE_VERSION" -lt 15 ]; then
    print_warning "Xcode 15+ is recommended. You have Xcode $XCODE_VERSION"
fi

# Check for Command Line Tools
echo ""
echo "Checking for Xcode Command Line Tools..."
if ! xcode-select -p &> /dev/null; then
    print_warning "Command Line Tools not found. Installing..."
    xcode-select --install
    echo "Please complete the installation and run this script again."
    exit 0
fi
print_success "Command Line Tools installed"

# Check for CocoaPods
echo ""
echo "Checking for CocoaPods..."
if ! command -v pod &> /dev/null; then
    print_warning "CocoaPods not found. Installing..."
    sudo gem install cocoapods
    print_success "CocoaPods installed"
else
    print_success "CocoaPods found: $(pod --version)"
fi

# Install dependencies
echo ""
echo "Installing dependencies..."
if [ -f "Podfile" ]; then
    pod install
    print_success "Dependencies installed via CocoaPods"
else
    print_warning "No Podfile found. Using Swift Package Manager only."
fi

# Check for Fastlane
echo ""
echo "Checking for Fastlane..."
if ! command -v fastlane &> /dev/null; then
    print_warning "Fastlane not found. Installing..."
    sudo gem install fastlane
    print_success "Fastlane installed"
else
    print_success "Fastlane found: $(fastlane --version | head -n 1)"
fi

# Create directories if they don't exist
echo ""
echo "Verifying project structure..."
mkdir -p DerivedData
mkdir -p fastlane/screenshots
print_success "Project structure verified"

# SwiftLint (optional)
echo ""
echo "Checking for SwiftLint (optional)..."
if ! command -v swiftlint &> /dev/null; then
    print_warning "SwiftLint not found. You can install it with: brew install swiftlint"
else
    print_success "SwiftLint found: $(swiftlint version)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print_success "Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Open BobTheBuilder.xcworkspace in Xcode"
if [ -f "BobTheBuilder.xcworkspace" ]; then
    echo "     $ open BobTheBuilder.xcworkspace"
else
    echo "     $ open BobTheBuilder.xcodeproj"
fi
echo "  2. Select your development team in Xcode"
echo "  3. Build and run (Cmd + R)"
echo ""
echo "For more information, see README.md"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
