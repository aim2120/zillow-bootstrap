# Bootstrap Scripts

This directory contains scripts to set up a complete macOS development environment.

## Files

- **`Brewfile`** - Homebrew bundle file containing all installed formulae, casks, and VS Code extensions
- **`bootstrap.sh`** - Main installation script that installs Homebrew and all packages from Brewfile
- **`helpers.sh`** - Shared helper functions for logging, user interaction, and system checks
- **`setup-chezmoi.sh`** - Script to set up chezmoi with existing dotfiles repository
- **`setup-xcode.sh`** - Script to install Xcode via xcodes

## Usage

### Quick Setup (Recommended)

Run the main bootstrap script from the bootstrap directory:

```bash
cd bootstrap
./bootstrap.sh
```

This will install all development tools, set up dotfiles via chezmoi, and optionally install Xcode.

### Individual Scripts

You can also run individual scripts as needed:

1. **Install development tools:**

   ```bash
   cd bootstrap
   ./bootstrap.sh
   ```

2. **Set up dotfile management:**

   ```bash
   cd bootstrap
   ./setup-chezmoi.sh
   ```

   This will initialize chezmoi with your existing dotfiles repository at https://github.com/aim2120/dotfiles

3. **Install Xcode:**
   ```bash
   cd bootstrap
   ./setup-xcode.sh
   ```
   This will install Xcode via xcodes (requires Apple ID authentication)

## Brewfile

The `Brewfile` contains all your currently installed Homebrew packages, including:

- Formulae (command-line tools) including git-subrepo
- Casks (GUI applications)
- VS Code extensions
- Custom taps

To update the Brewfile with your current installations:

```bash
brew bundle dump --file=Brewfile
```

## Prerequisites

- macOS (tested on macOS 10.15+)
- Internet connection
- Administrator privileges (for some installations)

## What Gets Installed

The bootstrap script installs:

- Xcode Command Line Tools
- Homebrew
- Chezmoi for dotfile management
- All packages from Brewfile (development tools, applications, VS Code extensions)
- Powerlevel10k zsh theme
- Essential development directories
- Optionally installs Xcode via xcodes

## Troubleshooting

- If you encounter permission issues, ensure you're not running as root
- If Homebrew installation fails, check your internet connection
- If repository cloning fails, verify your SSH keys are set up correctly
- For VS Code extensions, ensure VS Code is installed first

## Links

- [dotfiles](https://github.com/aim2120/dotfiles)
- [chezmoi](https://www.chezmoi.io)
- [xcodes](https://github.com/XcodesOrg/xcodes)
- [brew](https://brew.sh)
