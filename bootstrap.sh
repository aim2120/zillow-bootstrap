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
git config --global user.name "$(id -F)"
git config --global user.email "$(id -un)@zillowgroup.com"

# Install Homebrew if not present
if ! command_exists brew; then
    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    
    log_success "Homebrew installed successfully"
else
    log_success "Homebrew already installed"
fi

# Update Homebrew
log_info "Updating Homebrew..."
brew update

# Install chezmoi first for early dotfile setup (including SSH keys)
log_info "Installing chezmoi for early dotfile setup..."
brew install chezmoi
log_success "Chezmoi installed"

if [[ ! -f ~/.chezmoidata.yaml ]]; then
    log_warning "~/.chezmoidata.yaml does not exist"
    log_info "Please create a ~/.chezmoidata.yaml file (this has been stored in Keeper)"
    wait_for_user "When you're ready, press any key to continue..."
fi

# Set up chezmoi for dotfile management (including SSH keys and zshrc)
log_info "Setting up chezmoi for dotfile management..."
if [[ -d "$HOME/.local/share/chezmoi" ]]; then
    log_warning "Chezmoi is already initialized"
    if ! ask_confirmation "Do you want to reinitialize? This will overwrite existing configuration."; then
        log_info "Keeping existing chezmoi configuration"
    else
        log_info "Reinitializing chezmoi..."
        chezmoi init https://github.com/aim2120/dotfiles
        chezmoi apply
        log_success "Chezmoi reinitialized and dotfiles applied"
    fi
else
    log_info "Initializing chezmoi with existing dotfiles repository..."
    chezmoi init https://github.com/aim2120/dotfiles
    log_info "Applying dotfiles (including SSH keys and zshrc)..."
    chezmoi apply
    log_success "Chezmoi initialized and dotfiles applied"
fi

# Install remaining packages from Brewfile (now that SSH keys are available)
log_info "Installing remaining packages from Brewfile..."
if [[ -f "Brewfile" ]]; then
    brew bundle install --file=Brewfile
    log_success "All packages installed from Brewfile"
else
    log_error "Brewfile not found in current directory"
    exit 1
fi

# Install powerlevel10k theme for zsh (if not already configured via chezmoi)
log_info "Setting up zsh with powerlevel10k..."
if [[ ! -d "$HOME/powerlevel10k" ]]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
    log_success "Powerlevel10k installed"
else
    log_success "Powerlevel10k already installed"
fi

# Source zshrc if it exists (created by chezmoi)
if [[ -f ~/.zshrc ]]; then
    source ~/.zshrc
else
    log_warning "~/.zshrc not found - you may need to restart your terminal or run 'source ~/.zshrc' manually"
fi

# Ask user if they want to install Xcode
log_info "Xcode installation available via xcodes..."
if ask_confirmation "Do you want to install Xcode now? This will take a while and requires Apple ID authentication."; then
    log_info "Starting Xcode installation..."
    if [[ -f "setup-xcode.sh" ]]; then
        chmod +x setup-xcode.sh
        if ./setup-xcode.sh; then
            log_success "Xcode installation completed"
        else
            log_warning "Xcode installation had some issues, but continuing with bootstrap..."
        fi
    else
        log_error "setup-xcode.sh not found"
    fi
else
    log_info "Skipping Xcode installation"
    log_info "You can run ./setup-xcode.sh later to install Xcode"
fi

# Create necessary directories
log_info "Creating development directories..."
ensure_dir ~/bin
ensure_dir ~/scripts
ensure_dir ~/External
ensure_dir ~/zillow
ensure_dir ~/Playgrounds

# Clean up
log_info "Cleaning up..."
brew cleanup

log_success "Bootstrap completed successfully! 🚀"
