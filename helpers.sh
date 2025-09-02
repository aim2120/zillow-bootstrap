#!/bin/bash

# Shared helper functions for bootstrap scripts
# Source this file in other scripts: source "$(dirname "$0")/helpers.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on macOS
check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_error "This script is designed for macOS only"
        exit 1
    fi
}

# Check if running as root
check_not_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root"
        exit 1
    fi
}

# Check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check if a file exists
file_exists() {
    [[ -f "$1" ]]
}

# Check if a directory exists
dir_exists() {
    [[ -d "$1" ]]
}

# Ask for user confirmation
ask_confirmation() {
    local prompt="$1"
    local default="${2:-N}"
    
    if [[ "$default" == "Y" ]]; then
        read -p "$prompt (Y/n): " -n 1 -r
        echo
        [[ $REPLY =~ ^[Nn]$ ]] && return 1
    else
        read -p "$prompt (y/N): " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]] && return 0
    fi
    return 1
}

# Wait for user input
wait_for_user() {
    local message="${1:-Press any key to continue...}"
    read -p "$message" -n 1 -r
    echo
}

# Run a command with error handling
run_command() {
    local cmd="$1"
    local description="${2:-Running command}"
    
    log_info "$description..."
    if eval "$cmd"; then
        log_success "$description completed"
        return 0
    else
        log_error "$description failed"
        return 1
    fi
}

# Create directory if it doesn't exist
ensure_dir() {
    local dir="$1"
    if ! dir_exists "$dir"; then
        log_info "Creating directory: $dir"
        mkdir -p "$dir"
    fi
}
