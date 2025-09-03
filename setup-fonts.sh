#!/bin/bash

# Script to download and install MesloLGS NF fonts
# These fonts are commonly used with Nerd Fonts and terminal configurations

set -e

# Source shared helper functions
source "$(dirname "$0")/helpers.sh"

# Font URLs from the official Nerd Fonts repository
FONT_BASE_URL="https://github.com/romkatv/powerlevel10k-media/raw/master"
FONTS=(
    "MesloLGS NF Regular.ttf"
    "MesloLGS NF Bold.ttf"
    "MesloLGS NF Italic.ttf"
    "MesloLGS NF Bold Italic.ttf"
)

# Font directory
FONT_DIR="${HOME}/Library/Fonts"

log_info "Setting up MesloLGS NF fonts..."

# Create font directory if it doesn't exist
ensure_dir "${FONT_DIR}"

# Download and install each font
for font in "${FONTS[@]}"; do
    # URL encode the font name (replace spaces with %20)
    font_url_encoded=$(echo "${font}" | sed 's/ /%20/g')
    font_url="${FONT_BASE_URL}/${font_url_encoded}"
    font_path="${FONT_DIR}/${font}"
    
    if [[ -f "${font_path}" ]]; then
        log_success "Font already installed: ${font}"
    else
        log_info "Downloading ${font}..."
        if curl -fsSL "${font_url}" -o "${font_path}"; then
            log_success "Downloaded and installed: ${font}"
        else
            log_error "Failed to download: ${font}"
            exit 1
        fi
    fi
done

# Refresh font cache
log_info "Refreshing font cache..."
if command_exists fc-cache; then
    fc-cache -f -v
else
    # On macOS, we can use the system to refresh fonts
    log_info "Fonts installed. You may need to restart applications to see the new fonts."
fi

log_success "All MesloLGS NF fonts installed successfully! 🎨"
log_info "You can now use these fonts in your terminal and other applications."
