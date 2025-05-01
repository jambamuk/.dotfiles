#!/bin/bash
# Install script for Ubuntu

# Exit immediately if a command exits with a non-zero status.
set -e

# Function to check if a command exists
command_exists() {
  # Check if the command ($1) is available in the PATH
  command -v "$1" >/dev/null 2>&1
}

# Function to install packages if missing
install_if_missing() {
  # Local array to hold package names passed as arguments
  local packages=("$@")
  # Local array to hold packages that are found to be missing
  local missing_packages=()

  # Loop through each package name provided
  for pkg in "${packages[@]}"; do
    # Check if the command associated with the package exists
    if ! command_exists "$pkg"; then
      # If not found, add it to the list of missing packages
      missing_packages+=("$pkg")
    fi
  done # End of the for loop

  # Check if the missing_packages array has any elements
  if [ ${#missing_packages[@]} -gt 0 ]; then
    # If there are missing packages, print a message and install them
    echo "Installing missing packages: ${missing_packages[*]}..."
    # Update package lists first
    sudo apt update
    # Install the missing packages non-interactively
    sudo apt install -y "${missing_packages[@]}"
  else
    # If no packages were missing, print a confirmation message
    echo "All required packages already installed: ${packages[*]}."
  fi
} # End of install_if_missing function

# Function to clean up existing symlinks potentially managed by stow before restowing
# This helps prevent conflicts if stow was run previously or manually created links exist.
cleanup_stow_symlinks() {
  local package="$1"                   # The name of the stow package (e.g., "nvim", "zsh")
  local dotfiles_dir="$HOME/.dotfiles" # Path to the dotfiles directory

  echo "Cleaning up potential conflicting symlinks for '$package'..."

  # Check if the source directory for the stow package exists within .dotfiles
  if [ ! -d "$dotfiles_dir/$package" ]; then
    echo "Warning: Stow package directory '$dotfiles_dir/$package' not found. Skipping cleanup for '$package'."
    return 0 # Exit the function successfully; not finding the source isn't an error here
  fi

  # Run the find command in a subshell to avoid changing the script's main directory
  (
    # Change directory into the specific stow package directory
    cd "$dotfiles_dir/$package" || {
      echo "Error: Could not change directory to $dotfiles_dir/$package"
      return 1
    }

    # Find all files and directories directly inside the current directory (. is $dotfiles_dir/$package)
    # -maxdepth 1: Don't go into subdirectories of the items found
    # -mindepth 1: Don't include the '.' directory itself
    # -print0: Print items separated by a null character (safer for weird filenames)
    find . -maxdepth 1 -mindepth 1 -print0 | while IFS= read -r -d $'\0' source_item; do
      # Remove the leading './' from the found item path (e.g., './.bashrc' -> '.bashrc')
      local item_name="${source_item#./}"
      # Determine the target path in the home directory.
      # ASSUMPTION: Stow links items from the package dir directly into HOME.
      # Example: nvim/.config/nvim/init.lua -> $HOME/.config/nvim/init.lua (This function might need adjustment for such cases)
      # Simple case handled here: zsh/.zshrc -> $HOME/.zshrc
      # NOTE: This simple logic might incorrectly identify targets for complex stow setups.
      local target_path="$HOME/$item_name" # Assumes items are directly in HOME (e.g., .zshrc, .tmux.conf)

      # Check if the target path exists AND is a symbolic link
      if [ -L "$target_path" ]; then
        echo "  Removing existing symlink: $target_path"
        # Remove the symlink
        rm "$target_path"
      # Check if the target path exists but is NOT a symlink (it's a regular file or directory)
      elif [ -e "$target_path" ]; then
        # Stow will likely fail if it tries to create a symlink where a real file/dir exists.
        echo "  Warning: Existing file/directory '$target_path' is NOT a symlink. Stow for '$package' may conflict. Manual intervention might be needed."
      fi
    done # End of the while loop reading find output
  )      # Subshell ends here, returning the script to its previous directory
}        # End of cleanup_stow_symlinks function

echo "Starting installation script..."

# Check for essential tools needed by the script itself
install_if_missing stow git curl

# Update package lists - good practice before installing anything
echo "Updating package lists..."
sudo apt update

# Install core system packages frequently used in development setups
echo "Installing core system packages..."
install_if_missing zsh tmux fzf ripgrep fd-find # Use fd-find for Ubuntu/Debian

# Optional: Create a symlink for fd-find to be called as fd
if command_exists fdfind && ! command_exists fd; then
  echo "Creating symlink for 'fd' command pointing to 'fdfind'..."
  # Find the full path of fdfind
  FDFIND_PATH=$(command -v fdfind)
  if [ -n "$FDFIND_PATH" ]; then
    # Create a symlink in a common bin directory (adjust if needed)
    sudo ln -s "$FDFIND_PATH" /usr/local/bin/fd || echo "Warning: Failed to create symlink for fd. Manual creation might be needed."
  else
    echo "Warning: Could not find fdfind path to create symlink."
  fi
fi

# Install Oh My Zsh if the installation directory doesn't exist
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  # Use the official installation command, running unattended to avoid prompts
  # It clones the repo and sets up initial files.
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "Oh My Zsh is already installed."
fi

# Install ASDF version manager
ASDF_DIR="$HOME/.asdf"
ASDF_VERSION="v0.16.0" # Specify desired ASDF version tag

# Check if ASDF command is already available
if command_exists asdf; then
  echo "ASDF command found. Assuming ASDF is already installed and sourced."
# Check if the ASDF directory exists, even if the command isn't sourced in the current (script's) shell
elif [ -d "$ASDF_DIR" ]; then
  echo "ASDF directory ($ASDF_DIR) found, but 'asdf' command not in PATH/sourced for this script."
  echo "Assuming ASDF is installed but needs sourcing setup."
  # Ensure sourcing lines are present in ~/.zshrc
  echo "Ensuring ASDF sourcing lines are in ~/.zshrc..."
  # Check if the main asdf.sh sourcing line exists, add if not
  if ! grep -q ". \"\$ASDF_DIR/asdf.sh\"" ~/.zshrc; then
    echo '# ASDF Setup' >>~/.zshrc
    echo ". \"\$ASDF_DIR/asdf.sh\"" >>~/.zshrc # Note: Corrected quoting for expansion
  fi
  # Check if the completions sourcing line exists, add if not
  if ! grep -q ". \"\$ASDF_DIR/completions/asdf.bash\"" ~/.zshrc; then
    echo ". \"\$ASDF_DIR/completions/asdf.bash\"" >>~/.zshrc # Note: Corrected quoting
  fi

  echo "Attempting to source ~/.zshrc to make 'asdf' command available within the script..."
  # Source the file in the current script's environment.
  # This does NOT affect the parent shell you ran the script from.
  # Use '. ~/.zshrc' which is equivalent to 'source ~/.zshrc' but more POSIX compliant
  . ~/.zshrc

  # Re-check if the command is available *now* within the script
  if command_exists asdf; then
    echo "ASDF command is now available after sourcing."
  else
    echo "Warning: ASDF directory exists, sourcing lines checked/added, but 'asdf' command still not found."
    echo "Manual check of ~/.zshrc and shell restart might be required."
  fi

else
  # Neither command nor directory found - proceed with full ASDF installation
  echo "ASDF command and directory ($ASDF_DIR) not found. Proceeding with full ASDF installation (version $ASDF_VERSION)..."
  # Clone the specified version of the ASDF repository
  git clone https://github.com/asdf-vm/asdf.git "$ASDF_DIR" --branch "$ASDF_VERSION" || {
    echo "Error: Failed to clone ASDF repository."
    exit 1
  }

  # Add ASDF sourcing lines to ~/.zshrc (important after cloning)
  echo "Adding ASDF sourcing lines to ~/.zshrc..."
  if ! grep -q ". \"\$ASDF_DIR/asdf.sh\"" ~/.zshrc; then
    echo '# ASDF Setup' >>~/.zshrc
    echo ". \"\$ASDF_DIR/asdf.sh\"" >>~/.zshrc
  fi
  if ! grep -q ". \"\$ASDF_DIR/completions/asdf.bash\"" ~/.zshrc; then
    echo ". \"\$ASDF_DIR/completions/asdf.bash\"" >>~/.zshrc
  fi

  # Source now to make it available for subsequent script steps
  echo "Sourcing ~/.zshrc to make 'asdf' command available..."
  . ~/.zshrc
  if ! command_exists asdf; then
    echo "Warning: ASDF installed and sourcing lines added, but 'asdf' command not found after sourcing."
    echo "Manual shell restart or 'source ~/.zshrc' may be required."
  fi
fi

# --- Use ASDF to manage tools ---

# Install Neovim using ASDF if the 'nvim' command isn't already found
if command_exists asdf; then
  if ! command_exists nvim; then
    echo "Installing Neovim via ASDF..."
    # Add the Neovim plugin to ASDF if it's not already added
    if ! asdf plugin list | grep -q "neovim"; then
      echo "Adding Neovim plugin to ASDF..."
      # Attempt to add the plugin; handle potential errors
      asdf plugin add neovim || { echo "Error: Failed to add asdf neovim plugin."; }
    else
      echo "ASDF Neovim plugin already added."
    fi

    # Check if the plugin was added successfully before proceeding
    if asdf plugin list | grep -q "neovim"; then
      # Find the latest stable version offered by the plugin
      LATEST_NEOVIM=$(asdf list-all neovim | grep -v - | grep -v 'nightly' | tail -n 1) # Attempt to get latest stable

      if [ -z "$LATEST_NEOVIM" ]; then
        echo "Error: Could not determine latest stable Neovim version via ASDF. Skipping Neovim install."
      # Check if this latest version is already installed by ASDF
      elif asdf list neovim | grep -q "$LATEST_NEOVIM"; then
        echo "Neovim latest stable ($LATEST_NEOVIM) is already installed via ASDF."
      else
        # Install the determined latest stable version
        echo "Installing Neovim latest stable ($LATEST_NEOVIM) via ASDF..."
        asdf install neovim "$LATEST_NEOVIM" || { echo "Error: Failed to install neovim $LATEST_NEOVIM via asdf."; }
        # Update ASDF shims after installing
        asdf reshim neovim || { echo "Warning: Failed to reshim neovim."; }
      fi

      # Set the installed version as the global default, if installation was successful
      if [ -n "$LATEST_NEOVIM" ] && asdf list neovim | grep -q "$LATEST_NEOVIM"; then
        echo "Setting Neovim $LATEST_NEOVIM as global via ASDF..."
        asdf global neovim "$LATEST_NEOVIM" || { echo "Error: Failed to set neovim global via asdf."; }
      elif [ -n "$LATEST_NEOVIM" ]; then
        # This case means we determined a version but it failed to install or isn't listed
        echo "Warning: Could not set Neovim $LATEST_NEOVIM as global because it does not appear to be installed by ASDF."
      fi
    else
      echo "Error: ASDF Neovim plugin not found or failed to add. Cannot install Neovim via ASDF."
    fi
  else
    echo "Neovim command ('nvim') already found. Skipping ASDF Neovim install."
    # Optional: Check if the existing nvim is managed by asdf
    # if [ "$(asdf which nvim)" != "$(command -v nvim)" ]; then ... fi
  fi
else
  echo "ASDF command not found. Cannot install Neovim via ASDF."
fi

# Install Oh My Zsh plugins by cloning their repositories if they don't exist
echo "Checking/Installing Oh My Zsh plugins..."
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
# zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  echo "Cloning zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions \
    "$ZSH_CUSTOM/plugins/zsh-autosuggestions" || { echo "Error: Failed to clone zsh-autosuggestions."; }
else
  echo "zsh-autosuggestions already cloned."
fi
# zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  echo "Cloning zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting \
    "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" || { echo "Error: Failed to clone zsh-syntax-highlighting."; }
else
  echo "zsh-syntax-highlighting already cloned."
fi
# zsh-autocomplete
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autocomplete" ]; then
  echo "Cloning zsh-autocomplete..."
  git clone https://github.com/marlonrichert/zsh-autocomplete \
    "$ZSH_CUSTOM/plugins/zsh-autocomplete" || { echo "Error: Failed to clone zsh-autocomplete."; }
else
  echo "zsh-autocomplete already cloned."
fi

# Ensure zsh-syntax-highlighting is sourced in .zshrc
# Note: Oh My Zsh usually handles sourcing for plugins listed in the 'plugins=(...)' array in .zshrc
# Manually sourcing might be needed if not using the OMZ plugin mechanism for it.
# Consider adding 'zsh-syntax-highlighting' to the plugins array in .zshrc instead.
echo "Ensuring zsh-syntax-highlighting source line exists in ~/.zshrc (alternative to adding to OMZ plugins array)..."
if ! grep -q "zsh-syntax-highlighting.zsh" ~/.zshrc; then
  echo '# Zsh Syntax Highlighting Setup (Manual Source)' >>~/.zshrc
  echo "source \"\$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh\"" >>~/.zshrc
  echo "Added manual source line for zsh-syntax-highlighting."
else
  echo "zsh-syntax-highlighting source line already present or handled by OMZ plugins array in ~/.zshrc."
fi

# Clone dotfiles repository if it doesn't exist locally
# IMPORTANT: Replace <your_github_repository_url> with your actual dotfiles URL
DOTFILES_REPO_URL="git@github.com:jambamuk/.dotfiles.git" # <<< --- SET YOUR REPO URL HERE --- <<<
DOTFILES_DIR="$HOME/.dotfiles"

# Check if the placeholder URL is still present
if [ "$DOTFILES_REPO_URL" = "<your_github_repository_url>" ]; then
  echo "--------------------------------------------------------------------------"
  echo "ERROR: Please edit the script and replace '<your_github_repository_url>'"
  echo "       with the actual URL of your dotfiles repository."
  echo "--------------------------------------------------------------------------"
  exit 1
fi

# Clone the repository if the target directory doesn't exist
if [ ! -d "$DOTFILES_DIR" ]; then
  echo "Cloning dotfiles from $DOTFILES_REPO_URL..."
  git clone "$DOTFILES_REPO_URL" "$DOTFILES_DIR" || {
    echo "Error: Failed to clone dotfiles repository from $DOTFILES_REPO_URL."
    exit 1
  }
else
  echo "Dotfiles directory $DOTFILES_DIR already exists. Skipping clone."
  # Optional: Update existing dotfiles repo
  # echo "Updating dotfiles repository..."
  # (cd "$DOTFILES_DIR" && git pull) || echo "Warning: Failed to update dotfiles repository."
fi

# Use GNU Stow to create symlinks from the dotfiles directory to the home directory
echo "Setting up symlinks with Stow..."
if [ -d "$DOTFILES_DIR" ]; then
  # Navigate into the dotfiles directory to run stow correctly
  cd "$DOTFILES_DIR" || {
    echo "Error: Could not navigate to $DOTFILES_DIR"
    exit 1
  }

  # Define the stow packages (these should be top-level directories in your .dotfiles repo)
  # Example: If you have .dotfiles/nvim/*, .dotfiles/zsh/*, etc.
  STOW_PACKAGES=("nvim" "zsh" "tmux") # Add other package names as needed

  # Loop through the defined packages
  for package in "${STOW_PACKAGES[@]}"; do
    # Check if a directory for this package actually exists in .dotfiles
    if [ -d "./$package" ]; then
      # Run the cleanup function first to remove potentially conflicting old links
      cleanup_stow_symlinks "$package"

      echo "Running stow for package '$package'..."
      # Run stow:
      # -v: verbose (shows actions)
      # -R: restow (re-links files, overwriting existing links from this package)
      # -t ~: target directory is the home directory
      # --no-folding: prevents merging directories if target exists (safer, less surprising)
      stow -v -R -t ~ "$package" --no-folding || {
        echo "Error: Stow command failed for '$package'. Check warnings above. Manual intervention may be needed."
        exit 1
      }
      # Note: `set -e` will cause script exit on stow failure here.
    else
      # If the package directory doesn't exist in .dotfiles, skip it
      echo "Warning: Stow package directory './$package' not found in $DOTFILES_DIR. Skipping stow for '$package'."
    fi
  done # End of stow packages loop

  # Go back to the directory the script was run from
  cd - >/dev/null
else
  # This should not happen if the clone was successful, but handles the case where cloning failed earlier
  echo "Warning: Dotfiles directory $DOTFILES_DIR not found. Skipping Stow setup."
fi

echo "-----------------------------------------------------"
echo "Installation and setup script finished successfully."
echo "IMPORTANT: You may need to restart your terminal or run 'source ~/.zshrc'"
echo "           manually in any open terminals to apply all changes (like ASDF paths and Zsh plugins)."
echo "-----------------------------------------------------"
