#!/bin/bash
# Dotfiles installation script

set -e  # Exit on error

# Get the directory where the script is located
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Installing dotfiles from $DOTFILES_DIR"

# Install essential packages
echo "Installing essential packages..."
sudo apt-get update -y
sudo apt-get install -y vim tmux zsh curl wget 

# Install UV package manager
echo "Installing uv..."
curl -LsSf https://astral.sh/uv/install.sh | sh

# Set up Oh My Zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "Oh My Zsh already installed, skipping..."
fi
echo "Installing zsh plugins..."
# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions 2>/dev/null || echo "zsh-autosuggestions already installed"

# zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting 2>/dev/null || echo "zsh-syntax-highlighting already installed"

# zsh-history-substring-search
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search 2>/dev/null || echo "zsh-history-substring-search already installed"

# Install bat and create alias if needed
echo "Installing bat..."
if ! command -v bat &> /dev/null; then
    sudo apt-get install -y bat
    
    # Check if bat is installed as batcat (Ubuntu/Debian specific)
    if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
        echo "Creating bat -> batcat symlink..."
        mkdir -p ~/.local/bin
        ln -sf /usr/bin/batcat ~/.local/bin/bat
    fi
else
    echo "bat already installed, skipping..."
fi
# Create symbolic links
echo "Creating symbolic links..."
ln -sf "$DOTFILES_DIR/.bashrc" "$HOME/.bashrc"
ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
ln -sf "$DOTFILES_DIR/.vimrc" "$HOME/.vimrc"
ln -sf "$DOTFILES_DIR/.nanorc" "$HOME/.nanorc"
ln -sf "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"

# Create .local/bin if it doesn't exist
mkdir -p "$HOME/.local/bin"
# Link the env file
if [ -f "$DOTFILES_DIR/.local/bin/env" ]; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$DOTFILES_DIR/.local/bin/env" "$HOME/.local/bin/env"
    chmod +x "$DOTFILES_DIR/.local/bin/env"  # Make the source file executable, not the symlink
else
    echo "Warning: env file not found in dotfiles"
fi
# Set up ghostty config if needed
if [ -d "$DOTFILES_DIR/ghostty" ]; then
    mkdir -p "$HOME/.config"
    ln -sf "$DOTFILES_DIR/ghostty" "$HOME/.config/ghostty"
fi

# Set zsh as default shell
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "Setting zsh as default shell..."
    chsh -s $(which zsh)
    echo "Shell changed to zsh. You may need to log out and back in for this to take effect."
fi

echo "Dotfiles installation complete!"
# Set zsh as default shell
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "Setting zsh as default shell..."
    sudo chsh -s $(which zsh) $USER
    echo "Shell changed to zsh. You may need to log out and back in for this to take effect."
fi

# Execute zsh immediately after installation
echo "Starting zsh..."
exec zsh -l