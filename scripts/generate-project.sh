#!/bin/bash

# generate-project.sh
# Script to generate the Xcode project using XcodeGen

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔨 Bob the Builder - Xcode Project Generator"
echo "============================================="
echo ""

# Check if xcodegen is installed
if ! command -v xcodegen &> /dev/null; then
    echo -e "${YELLOW}⚠️  XcodeGen is not installed${NC}"
    echo ""
    echo "Would you like to install it? (y/n)"
    echo ""
    echo "Installation options:"
    echo "1. Using Homebrew: brew install xcodegen"
    echo "2. Using Mint: mint install yonaskolb/XcodeGen"
    echo "3. Download from: https://github.com/yonaskolb/XcodeGen/releases"
    echo ""

    read -p "Install using Homebrew now? (y/n): " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Installing XcodeGen via Homebrew..."
        brew install xcodegen

        if [ $? -ne 0 ]; then
            echo -e "${RED}❌ Failed to install XcodeGen via Homebrew${NC}"
            echo "Please install manually and try again."
            exit 1
        fi
    else
        echo -e "${RED}❌ XcodeGen is required to generate the project${NC}"
        echo "Please install XcodeGen and run this script again."
        exit 1
    fi
fi

echo -e "${GREEN}✓ XcodeGen is installed${NC}"
echo ""

# Navigate to project root
cd "$(dirname "$0")/.."

# Check if project.yml exists
if [ ! -f "project.yml" ]; then
    echo -e "${RED}❌ project.yml not found${NC}"
    echo "Please ensure you're running this script from the project root."
    exit 1
fi

echo "📝 Generating Xcode project from project.yml..."
xcodegen generate

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Xcode project generated successfully!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Open the project: open BobTheBuilder.xcodeproj"
    echo "2. Select your development team in Signing & Capabilities"
    echo "3. Build and run: ⌘+R"
    echo ""
else
    echo -e "${RED}❌ Failed to generate Xcode project${NC}"
    exit 1
fi
