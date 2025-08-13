#!/bin/bash

# Dotfiles installation script
# This script creates symbolic links from the home directory to dotfiles

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the directory where this script is located
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to create symbolic link
create_symlink() {
    local source=$1
    local target=$2
    
    # Check if target already exists
    if [ -e "$target" ] || [ -L "$target" ]; then
        if [ -L "$target" ]; then
            # It's a symlink
            print_warning "$target already exists as a symlink. Removing..."
            rm "$target"
        else
            # It's a regular file/directory
            print_warning "$target already exists. Backing up to ${target}.backup"
            mv "$target" "${target}.backup"
        fi
    fi
    
    # Create the symlink
    ln -s "$source" "$target"
    print_info "Created symlink: $target -> $source"
}

# Main installation
print_info "Starting dotfiles installation..."
print_info "Dotfiles directory: $DOTFILES_DIR"

# Create necessary directories
print_info "Creating necessary directories..."
mkdir -p ~/.config

# Zsh configuration
print_info "Setting up Zsh configuration..."
create_symlink "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"

# Git configuration
print_info "Setting up Git configuration..."
create_symlink "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
create_symlink "$DOTFILES_DIR/git/.gitignore_global" "$HOME/.gitignore_global"

# Tmux configuration
print_info "Setting up Tmux configuration..."
create_symlink "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"

# Vim configuration (if exists)
if [ -d "$DOTFILES_DIR/vim" ]; then
    print_info "Setting up Vim configuration..."
    create_symlink "$DOTFILES_DIR/vim/.vimrc" "$HOME/.vimrc"
fi

# Starship configuration (if exists)
if [ -f "$DOTFILES_DIR/starship/starship.toml" ]; then
    print_info "Setting up Starship configuration..."
    create_symlink "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
fi

# Create .env.local from example if it doesn't exist
if [ ! -f "$HOME/.env.local" ]; then
    print_info "Creating .env.local from template..."
    cp "$DOTFILES_DIR/.env.example" "$HOME/.env.local"
    print_warning "Please edit ~/.env.local and add your actual API keys and passwords"
else
    print_info ".env.local already exists, skipping..."
fi

print_info "Dotfiles installation completed!"
print_info ""
print_info "Next steps:"
print_info "1. Edit ~/.env.local and add your API keys and passwords"
print_info "2. Restart your terminal or run: source ~/.zshrc"
print_info "3. Initialize git repository: cd $DOTFILES_DIR && git init"
print_info "4. Add your remote repository: git remote add origin <your-repo-url>"