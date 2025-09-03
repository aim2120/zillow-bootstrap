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
CURRENT_VERSION=$(xcodebuild -version | head -n1 | awk '{print $2}' || true)
if [[ -n "${CURRENT_VERSION}" ]]; then
    log_warning "Xcode $CURRENT_VERSION is already installed"
    exit 0
fi

# Install Xcode
log_info "Installing Xcode..."
log_warning "This may take a while depending on your internet connection..."

INSTALL_SUCCESS=0
xcodes install --latest --experimental-unxip || INSTALL_SUCCESS=$?

if [[ ${INSTALL_SUCCESS} -eq 0 ]]; then
    log_success "Xcode installed successfully"
else
    log_warning "Xcode not installed fully, please confirm before proceeding"
    wait_for_user "When you're ready, press any key to continue..."
fi

INSTALLED_VERSION=$(xcodes list | grep -E "Installed" | awk '{print $2}')
log_info "Installed Xcode version: ${INSTALLED_VERSION}"
xcodes select "${INSTALLED_VERSION}"

sudo xcodebuild -license accept

# Final verification
log_info "Verifying Xcode installation..."
xcodebuild -version
xcode-select -p

log_success "🎉 Xcode installation completed successfully!"
