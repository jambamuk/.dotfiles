#!/bin/bash
# Install script for Ubuntu

# Exit immediately if a command exits with a non-zero status.
set -e

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to install packages if missing
install_if_missing() {
  local packages=("$@")
  local missing_packages=()
  for pkg in "${packages[@]}"; do
    if ! command_exists "$pkg"; then
      missing_packages+=("$pkg")
    fi
  }

  if [ ${#missing_packages[@]} -gt 0 ]; then
    echo "Installing missing packages: ${missing_packages[*]}..."
    sudo apt update
    sudo apt install -y "${missing_packages[@]}"
  else
    echo "All required packages already installed: ${packages[*]}."
  fi
}

# Function to clean up existing symlinks managed by stow before restowing
cleanup_stow_symlinks() {
  local package="$1"
  local dotfiles_dir="$HOME/.dotfiles"

  echo "Cleaning up potential conflicting symlinks for '$package'..."

  if [ ! -d "$dotfiles_dir/$package" ]; then
    echo "Warning: Stow package directory '$dotfiles_dir/$package' not found. Skipping cleanup for '$package'."
    return 0 # Not an error if the source package doesn't exist
  fi

  # Navigate to the package directory to easily list its contents
  (
    cd "$dotfiles_dir/$package" || { echo "Error: Could not change directory to $dotfiles_dir/$package"; return 1; }

    # Use find to list all files/directories in the package, respecting hidden files.
    # -maxdepth 1 and -mindepth 1 look only at direct children.
    find . -maxdepth 1 -mindepth 1 -print0 | while IFS= read -r -d $'\0' source_item; do
      # Remove leading './'
      local item_name="${source_item#./}"
      # Determine the target path in the home directory. Stow often links to .$item_name
      # This is a simplification and assumes items like .bashrc -> ~/.bashrc, not config/nvim -> ~/.config/nvim
      # For complex structures like nvim linking into ~/.config, this cleanup might be insufficient.
      local target_path="$HOME/.$item_name"

      # Check if the target exists and is a symlink
      if [ -L "$target_path" ]; then
        echo "  Removing existing symlink: $target_path"
        rm "$target_path"
      elif [ -e "$target_path" ]; then
           # If it exists but is NOT a symlink, stow will likely conflict unless it's ignored.
           echo "  Warning: Existing file/directory '$target_path' is NOT a symlink. Stow for '$package' may conflict. Manual intervention might be needed."
      fi
    done
  ) # Subshell ends here, returning to the original directory
}


echo "Starting installation script..."

# Check for necessary tools (using the new function)
install_if_missing stow git curl

# Update package lists - always a good idea before installing
sudo apt update

# Install core system packages if missing (using the new function)
install_if_missing zsh tmux fzf ripgrep fd

# Install Oh My Zsh if not already present
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  # Use the official installation command from Oh My Zsh's repository
  # The 'unattended' flag prevents it from trying to change your default shell
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "Oh My Zsh is already installed."
fi

# Install ASDF (Go version v0.16.0) - More robust check
ASDF_DIR="$HOME/.asdf"
ASDF_VERSION="v0.16.0" # As per the guide

if command_exists asdf; then
  echo "ASDF command found. Assuming ASDF is already installed and sourced."
elif [ -d "$ASDF_DIR" ]; then
  echo "ASDF directory ($ASDF_DIR) found, but 'asdf' command not in PATH/sourced."
  echo "Assuming ASDF is installed but not fully set up in this shell."
  echo "Skipping git clone. Proceeding to ensure sourcing and availability."
  # Ensure sourcing lines are present and source
  echo "Ensuring ASDF sourcing lines are in ~/.zshrc..."
  if ! grep -q ". \"\$ASDF_DIR/asdf.sh\"" ~/.zshrc; then
    echo '# ASDF Setup' >> ~/.zshrc
    echo '. "$ASDF_DIR/asdf.sh"' >> ~/.zshrc
  fi
  if ! grep -q ". \"\$ASDF_DIR/completions/asdf.bash\"" ~/.zshrc; then
     echo '. "$ASDF_DIR/completions/asdf.bash"' >> ~/.zshrc
  fi

  echo "Sourcing ~/.zshrc to make 'asdf' command available..."
  # Using exec bash -l or exec zsh -l might be more reliable to fully load the new config
  # but will replace the current shell running the script. Simple source is used for now.
  source ~/.zshrc

  # Re-check if command exists after sourcing attempt
  if command_exists asdf; then
    echo "ASDF command is now available after sourcing."
  else
    echo "Warning: ASDF directory exists, sourcing lines added, but 'asdf' command still not found."
    echo "Manual intervention may be required (e.g., check ~/.zshrc, shell configuration)."
  fi

else
  # Neither command nor directory found - proceed with full install including git clone
  echo "ASDF command and directory ($ASDF_DIR) not found. Proceeding with full ASDF installation (Go version $ASDF_VERSION)..."
  git clone https://github.com/asdf-vm/asdf.git "$ASDF_DIR" --branch "$ASDF_VERSION" || { echo "Error: Failed to clone ASDF repository."; exit 1; }

  # Add ASDF sourcing if not present (handled above, but repeating here for clarity in this block)
  echo "Adding ASDF sourcing lines to ~/.zshrc..."
   if ! grep -q ". \"\$ASDF_DIR/asdf.sh\"" ~/.zshrc; then
    echo '# ASDF Setup' >> ~/.zshrc
    echo '. "$ASDF_DIR/asdf.sh"' >> ~/.zshrc
  fi
  if ! grep -q ". \"\$ASDF_DIR/completions/asdf.bash\"" ~/.zshrc; then
     echo '. "$ASDF_DIR/completions/asdf.bash"' >> ~/.zshrc
  fi

  # Source now
  echo "Sourcing ~/.zshrc to make 'asdf' command available..."
  source ~/.zshrc
  if ! command_exists asdf; then
      echo "Warning: ASDF installed and sourcing lines added, but 'asdf' command not found after sourcing."
      echo "Manual intervention may be required."
  fi
fi


# --- ASDF commands use the standard syntax: global, local, shell ---

# Install Neovim (via ASDF) if nvim command isn't found
# This assumes if nvim exists, it's already been handled by ASDF or manually.
if command_exists asdf; then
  if ! command_exists nvim; then
    echo "Installing Neovim via ASDF..."
    # Add Neovim plugin if not already added
    if ! asdf plugin list | grep -q "neovim"; then
      echo "Adding Neovim plugin to ASDF..."
      asdf plugin add neovim || { echo "Error: Failed to add asdf neovim plugin."; }
    else
      echo "ASDF Neovim plugin already added."
    fi

    # Install the latest stable version available via the plugin
    LATEST_NEOVIM=$(asdf latest neovim)
    if [ -z "$LATEST_NEOVIM" ]; then
        echo "Error: Could not determine latest Neovim version via ASDF. Skipping Neovim install."
    elif asdf list neovim | grep -q "$LATEST_NEOVIM"; then
      echo "Neovim latest ($LATEST_NEOVIM) is already installed via ASDF."
    else
       echo "Installing Neovim latest ($LATEST_NEOVIM) via ASDF..."
       asdf install neovim latest || { echo "Error: Failed to install neovim latest via asdf."; }
       # Need to reshim after installing
       asdf reshim neovim || { echo "Warning: Failed to reshim neovim."; }
    fi

    # Set as global using the standard 'asdf global' command
    # This command is idempotent - setting it again causes no harm.
    if [ -n "$LATEST_NEOVIM" ] && asdf list neovim | grep -q "$LATEST_NEOVIM"; then
        echo "Setting Neovim latest ($LATEST_NEOVIM) as global via ASDF..."
        asdf global neovim latest || { echo "Error: Failed to set neovim global via asdf."; }
    elif [ -n "$LATEST_NEOVIM" ]; then
        echo "Warning: Could not set Neovim latest ($LATEST_NEOVIM) as global because it does not appear to be installed."
    fi

  else
     echo "Neovim command already found. Skipping ASDF Neovim install."
     # Optional: Could add logic here to check if the found nvim is the one ASDF manages
  fi
else
  echo "ASDF command not found. Cannot install Neovim via ASDF."
fi


# Install Oh My Zsh plugins if not already present
echo "Checking/Installing Oh My Zsh plugins..."
  # zsh-autosuggestions
  if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
    echo "Cloning zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions \
      "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" || { echo "Error: Failed to clone zsh-autosuggestions."; }
  else
    echo "zsh-autosuggestions already cloned."
  fi
  # zsh-syntax-highlighting
  if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
    echo "Cloning zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting \
      "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" || { echo "Error: Failed to clone zsh-syntax-highlighting."; }
  else
    echo "zsh-syntax-highlighting already cloned."
  fi
  # zsh-autocomplete
  if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autocomplete" ]; then
    echo "Cloning zsh-autocomplete..."
    git clone https://github.com/marlonrichert/zsh-autocomplete \
      "$HOME/.oh-my-zsh/custom/plugins/zsh-autocomplete" || { echo "Error: Failed to clone zsh-autocomplete."; }
  else
     echo "zsh-autocomplete already cloned."
  fi

# Source zsh-syntax-highlighting in .zshrc if not already present
if ! grep -q "zsh-syntax-highlighting.zsh" ~/.zshrc; then
  echo '# Zsh Syntax Highlighting Setup' >> ~/.zshrc
  echo "source \$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc
else
  echo "zsh-syntax-highlighting already sourced in ~/.zshrc."
fi


# Clone dotfiles if the directory doesn't exist
# IMPORTANT: Replace <your_github_repository_url> with your actual dotfiles URL
DOTFILES_REPO_URL="<your_github_repository_url>" # Set your repo URL here
DOTFILES_DIR="$HOME/.dotfiles"

if [ "$DOTFILES_REPO_URL" = "<your_github_repository_url>" ]; then
    echo "ERROR: Please update DOTFILES_REPO_URL in the script with your actual repository URL."
    exit 1
fi

if [ ! -d "$DOTFILES_DIR" ]; then
  echo "Cloning dotfiles from $DOTFILES_REPO_URL..."
  git clone "$DOTFILES_REPO_URL" "$DOTFILES_DIR" || { echo "Error: Failed to clone dotfiles repository."; exit 1; }
else
  echo "Dotfiles directory $DOTFILES_DIR already exists. Skipping clone."
  # Optional: Could add git pull origin main/master here to update existing dotfiles
  # echo "Updating dotfiles..."
  # (cd "$DOTFILES_DIR" && git pull)
fi

# Stow setup
echo "Setting up symlinks with Stow..."
if [ -d "$DOTFILES_DIR" ]; then
  # Navigate to the dotfiles directory before using stow
  cd "$DOTFILES_DIR" || { echo "Error: Could not navigate to $DOTFILES_DIR"; exit 1; }

  # Packages to stow. Ensure these directories exist in your dotfiles repo.
  # The cleanup_stow_symlinks function assumes these link directly into HOME/.<package_item>
  # If your stow package links elsewhere (e.g., nvim -> ~/.config/nvim), the cleanup might need adjustment.
  STOW_PACKAGES=("nvim" "zsh" "tmux") # Removed 'asdf' from here unless you manage ~/.asdf structure with stow

  # Optional: Add 'asdf' here if you manage files directly under ~/.asdf with stow
  # STOW_PACKAGES+=("asdf")

  for package in "${STOW_PACKAGES[@]}"; do
    if [ -d "./$package" ]; then # Check if the package directory exists in dotfiles
      cleanup_stow_symlinks "$package" # Clean up potential symlinks in HOME

      echo "Running stow for package '$package'..."
      # --no-folding prevents merging directories if the target exists and is a directory (safer)
      stow "$package" --no-folding || { echo "Error: Failed to stow '$package'. Check warnings above or manual intervention may be needed."; exit 1; }
    else
      echo "Warning: Stow package directory './$package' not found in $DOTFILES_DIR. Skipping stow for '$package'."
    fi
  done

  cd - >/dev/null # Return to the previous directory
else
  echo "Warning: Dotfiles directory $DOTFILES_DIR not found. Skipping Stow setup."
fi

echo "Installation and setup script finished."
echo "You may need to restart your terminal or run 'source ~/.zshrc' manually to apply changes."
