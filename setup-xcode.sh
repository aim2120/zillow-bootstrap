#!/bin/bash

# Xcode installation script using xcodes
# This script installs Xcode via xcodes and sets up the development environment

set -e

source "$(dirname "$0")/helpers.sh"

log_info "Starting Xcode installation via xcodes..."

# Check if xcodes is installed
if ! command -v xcodes &> /dev/null; then
    brew install xcodes
fi

# Get available Xcode versions
log_info "Fetching available Xcode versions..."
xcodes list

# Check if Xcode is already installed
if [[ -d "/Applications/Xcode.app" ]]; then
    CURRENT_VERSION=$(xcodebuild -version | head -n1 | awk '{print $2}')
    log_warning "Xcode $CURRENT_VERSION is already installed"
    if ! ask_confirmation "Do you want to install a different version? This will not remove the existing installation."; then
        log_info "Keeping existing Xcode installation"
        exit 0
    fi
fi

# Install Xcode
log_info "Installing Xcode..."
log_warning "This may take a while depending on your internet connection..."

xcodes install --latest --experimental-unxip

if [[ $? -eq 0 ]]; then
    log_success "Xcode installed successfully"
else
    log_error "Failed to install Xcode"
    exit 1
fi

# Verify command line tools
log_info "Verifying command line tools..."
if xcode-select -p &> /dev/null; then
    log_success "Command line tools are properly configured"
else
    log_warning "Command line tools may need manual configuration"
fi

# Final verification
log_info "Running final verification..."
echo "Xcode version: $(xcodebuild -version | head -n1)"
echo "Command line tools path: $(xcode-select -p)"
echo "Available simulators:"
xcrun simctl list devices | grep -E "(iPhone|iPad)" | head -5

log_success "🎉 Xcode installation completed successfully!"

