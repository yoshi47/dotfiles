#!/bin/bash

# Dotfiles uninstallation script
# This script removes symbolic links and restores backups if they exist

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to remove symlink and restore backup
remove_symlink() {
    local target=$1
    
    if [ -L "$target" ]; then
        rm "$target"
        print_info "Removed symlink: $target"
        
        # Check if backup exists
        if [ -e "${target}.backup" ]; then
            mv "${target}.backup" "$target"
            print_info "Restored backup: $target"
        fi
    else
        print_warning "$target is not a symlink, skipping..."
    fi
}

# Main uninstallation
print_info "Starting dotfiles uninstallation..."

# Remove Zsh configuration
print_info "Removing Zsh configuration..."
remove_symlink "$HOME/.zshrc"

# Remove Git configuration
print_info "Removing Git configuration..."
remove_symlink "$HOME/.gitconfig"
remove_symlink "$HOME/.gitignore_global"

# Remove Tmux configuration
print_info "Removing Tmux configuration..."
remove_symlink "$HOME/.tmux.conf"

# Remove Vim configuration
if [ -L "$HOME/.vimrc" ]; then
    print_info "Removing Vim configuration..."
    remove_symlink "$HOME/.vimrc"
fi

# Remove Starship configuration
if [ -L "$HOME/.config/starship.toml" ]; then
    print_info "Removing Starship configuration..."
    remove_symlink "$HOME/.config/starship.toml"
fi

# Remove Alacritty configuration
if [ -L "$HOME/.config/alacritty/alacritty.toml" ]; then
    print_info "Removing Alacritty configuration..."
    remove_symlink "$HOME/.config/alacritty/alacritty.toml"
    
    # Remove theme symlinks
    if [ -L "$HOME/.config/alacritty/themes/dracula.toml" ]; then
        remove_symlink "$HOME/.config/alacritty/themes/dracula.toml"
    fi
fi

print_info "Dotfiles uninstallation completed!"
print_warning "Note: .env.local was not removed for security reasons"