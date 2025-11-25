#!/bin/bash

# Setup script for Industrial Configurator iOS App
# This script should be run on macOS

set -e

echo "Setting up Industrial Configurator project..."

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install XcodeGen
if ! command -v xcodegen &> /dev/null; then
    echo "Installing XcodeGen..."
    brew install xcodegen
fi

# Generate Xcode project
echo "Generating Xcode project..."
xcodegen generate

echo "Setup complete! You can now open IndustrialConfigurator.xcodeproj in Xcode."
