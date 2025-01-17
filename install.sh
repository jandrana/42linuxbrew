#!/bin/bash

# Exit immediately on errors
set -e

# Variables
BREW_REPO="https://github.com/Homebrew/brew"
BREW_DIR="/sgoinfre/students/$USER/.brew"  
BREW_CONFIG="/sgoinfre/students/$USER/.brewconfig.zsh" 
ZSHRC="$HOME/.zshrc"

# Remove any existing Homebrew installation in the sgoinfre directory
echo "Removing any existing Homebrew installation..."
rm -rf "$BREW_DIR"
rm -rf "$HOME/.brew"

# Clone Homebrew repository to sgoinfre
echo "Cloning Homebrew repository..."
git clone --depth=1 "$BREW_REPO" "$BREW_DIR"

# Create .brewconfig.zsh script in sgoinfre directory
echo "Creating Homebrew configuration script..."
cat > "$BREW_CONFIG" <<EOL
# HOMEBREW CONFIGURATION

# Add brew to path
export PATH=/sgoinfre/students/\$USER/.brew/bin:\$PATH

# Set Homebrew temporary folders in sgoinfre
export HOMEBREW_CACHE=/sgoinfre/students/\$USER/Homebrew/Caches
export HOMEBREW_TEMP=/sgoinfre/students/\$USER/Homebrew/Temp

mkdir -p \$HOMEBREW_CACHE
mkdir -p \$HOMEBREW_TEMP

if df --output=fstype "\$HOME" | grep -E "autofs|nfs" >/dev/null; then
  HOMEBREW_LOCKS_TARGET="/sgoinfre/students/\$USER/Homebrew/Locks"
  HOMEBREW_LOCKS_FOLDER="/sgoinfre/students/\$USER/.brew/var/homebrew"

  # Create the target and locks folder if they don't exist
  mkdir -p "\$HOMEBREW_LOCKS_TARGET"
  mkdir -p "\$(dirname "\$HOMEBREW_LOCKS_FOLDER")"

  # Create a symlink for the Locks folder if it's not already a symlink
  if ! [[ -L "\$HOMEBREW_LOCKS_FOLDER" && -d "\$HOMEBREW_LOCKS_FOLDER" ]]; then
    echo "Creating symlink for Locks folder..."
    rm -rf "\$HOMEBREW_LOCKS_FOLDER"
    ln -s "\$HOMEBREW_LOCKS_TARGET" "\$HOMEBREW_LOCKS_FOLDER"
  fi
fi
EOL

# Add sourcing of .brewconfig.zsh to .zshrc if not already present
if ! grep -q "# Load Homebrew config script" "$ZSHRC"; then
  echo "Adding Homebrew config script to $ZSHRC..."
  cat >> "$ZSHRC" <<EOL

# Load Homebrew config script
source /sgoinfre/students/\$USER/.brewconfig.zsh
EOL
fi

# Source the config and rehash
echo "Loading Homebrew configuration..."
source "$BREW_CONFIG"
hash -r

# Update Homebrew
echo "Updating Homebrew..."
brew update

echo -e "\nHomebrew installation complete. Please open a new shell to finalize the setup."
