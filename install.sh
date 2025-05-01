#!/bin/bash
# Install script for Ubuntu

# Check for necessary tools
command -v stow >/dev/null 2>&1 || {
  echo "stow not found. Please install it."
  exit 1
}
command -v git >/dev/null 2>&1 || {
  echo "git not found. Please install it."
  exit 1
}
command -v curl >/dev/null 2>&1 || {
  echo "curl not found. Please install it."
  exit 1
}

# Update package lists
sudo apt update

# Install Zsh
if ! command -v zsh >/dev/null 2>&1; then
  echo "Installing Zsh..."
  sudo apt install -y zsh
fi

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  # Use the new installation command from Oh My Zsh's repository
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Install ASDF
if ! command -v asdf >/dev/null 2>&1; then
  echo "Installing ASDF..."
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch #  Use a specific tag
  echo '. "$HOME/.asdf/asdf.sh"' >>~/.zshrc
  echo '. "$HOME/.asdf/completions/asdf.bash"' >>~/.zshrc
  source ~/.zshrc
fi

# Install Neovim (via ASDF)
if ! asdf plugin list | grep -q "neovim"; then
  echo "Adding Neovim plugin to ASDF..."
  asdf plugin add neovim
fi
if ! command -v nvim >/dev/null 2>&1; then
  echo "Installing Neovim via ASDF..."
  # Install the latest stable version
  asdf install neovim latest
  asdf global neovim latest # Set as global
fi

# Install Tmux
if ! command -v tmux >/dev/null 2>&1; then
  echo "Installing Tmux..."
  sudo apt install -y tmux
fi

# Install fzf, ripgrep, and fd
echo "Installing fzf, ripgrep, and fd..."
sudo apt install -y fzf ripgrep fd

# Install Oh My Zsh plugins
echo "Installing Oh My Zsh plugins..."
# zsh-autosuggestions
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions \
    "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
fi
# zsh-syntax-highlighting
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting \
    "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
fi
# zsh-autocomplete
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autocomplete" ]; then
  git clone https://github.com/marlonrichert/zsh-autocomplete \
    "$HOME/.oh-my-zsh/custom/plugins/zsh-autocomplete"
fi

# Source zsh-syntax-highlighting
echo "Sourcing zsh-syntax-highlighting..."
echo "source \$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >>~/.zshrc

# Clone dotfiles
if [ ! -d "$HOME/.dotfiles" ]; then
  echo "Cloning dotfiles..."
  git clone git@github.com:jambamuk/.dotfiles.git
fi

# Stow
echo "Setting up symlinks with Stow..."
cd ~/.dotfiles # IMPORTANT: Navigate to the dotfiles directory before using stow
stow nvim
stow zsh
stow tmux
stow asdf

echo "Dotfiles setup complete!"
echo "You may need to restart your terminal."
