#!/bin/bash

# Bootstrap script for macOS development environment
# This script sets up homebrew, essential tools, and development environment

set -e

# Source shared helper functions
source "$(dirname "$0")/helpers.sh"

# Check system requirements
check_macos
check_not_root

log_info "Starting bootstrap process for macOS development environment..."

# Install Xcode Command Line Tools if not present
if ! xcode-select -p &> /dev/null; then
    log_info "Installing Xcode Command Line Tools..."
    xcode-select --install
    log_warning "Please complete the Xcode Command Line Tools installation and run this script again"
    exit 0
else
    log_success "Xcode Command Line Tools already installed"
fi

# Set up Git configuration (user will need to configure)
log_info "Setting up Git configuration..."
USER_NAME="$(id -F)"
USER_EMAIL="$(id -un)@zillowgroup.com"

if [[ -z "${USER_NAME}" || -z "${USER_EMAIL}" ]]; then
    log_error "User name or email not found"
    exit 1
fi
git config --global user.name "${USER_NAME}"
git config --global user.email "${USER_EMAIL}"

# Install Homebrew if not present
if ! command_exists brew; then
    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    log_success "Homebrew installed successfully"
else
    log_success "Homebrew already installed"
fi

# Update Homebrew
log_info "Updating Homebrew..."
brew update

# Install chezmoi first for early dotfile setup (including SSH keys)
./setup-chezmoi.sh

# Xcode needed before brew install
./setup-xcode.sh

# Install remaining packages from Brewfile (now that SSH keys are available)
log_info "Installing remaining packages from Brewfile..."
BREW_BUNDLE_SUCCESS=0
brew bundle install --file=Brewfile || BREW_BUNDLE_SUCCESS=$?
if [[ ${BREW_BUNDLE_SUCCESS} -eq 0 ]]; then
    log_success "All packages installed from Brewfile"
else
    log_warning "Failed to install packages from Brewfile, please confirm before proceeding"
    wait_for_user "When you're ready, press any key to continue..."
fi

log_info "Installing mise..."
curl https://mise.run | sh

log_info "Installing oh-my-zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install powerlevel10k theme for zsh (if not already configured via chezmoi)
log_info "Setting up zsh with powerlevel10k..."
if [[ ! -d "${HOME}/powerlevel10k" ]]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
    log_success "Powerlevel10k installed"
else
    log_success "Powerlevel10k already installed"
fi

# Source zshrc if it exists (created by chezmoi)
if [[ -f "${HOME}/.zshrc" ]]; then
    source "${HOME}/.zshrc"
else
    log_warning "~/.zshrc not found - you may need to restart your terminal or run 'source ~/.zshrc' manually"
fi

# Create necessary directories
log_info "Creating development directories..."
ensure_dir "${HOME}/bin"
ensure_dir "${HOME}/scripts"
ensure_dir "${HOME}/External"
ensure_dir "${HOME}/zillow"
ensure_dir "${HOME}/Playgrounds"

# Clean up
log_info "Cleaning up..."
brew cleanup

log_success "Bootstrap completed successfully! 🚀"
