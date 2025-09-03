#!/bin/bash

# Chezmoi setup script for dotfile management
# This script helps set up chezmoi for managing dotfiles

set -e

source "$(dirname "$0")/helpers.sh"

log_info "Setting up Chezmoi for dotfile management..."

if [[ ! -f "$HOME/.local/share/chezmoi/.chezmoidata.yaml" ]]; then
    log_error ~/.local/share/chezmoi/.chezmoidata.yaml does not exist
    log_info "Please create a ~/.local/share/chezmoid/.chezmoidata.yaml file (this has been stored in Keeper)"
    wait_for_user "When you're ready, press any key to continue..."
fi

# Check if chezmoi is installed
if ! command -v chezmoi &> /dev/null; then
    brew install chezmoi
fi

# Check if chezmoi is already initialized
if [[ -d "$HOME/.local/share/chezmoi" ]]; then
    log_warning "Chezmoi is already initialized"
    if ! ask_confirmation "Do you want to reinitialize? This will overwrite existing configuration."; then
        log_info "Keeping existing chezmoi configuration"
        exit 0
    fi
fi

# Initialize chezmoi
log_info "Initializing chezmoi..."

# Using existing dotfiles repository from https://github.com/aim2120/dotfiles

# Initialize chezmoi with the existing dotfiles repository
log_info "Initializing chezmoi with existing dotfiles repository..."
chezmoi init https://github.com/aim2120/dotfiles

# Apply the dotfiles
log_info "Applying dotfiles..."
chezmoi apply

log_success "Chezmoi setup completed! 🫡"
