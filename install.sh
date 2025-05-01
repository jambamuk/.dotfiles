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
  # Array to hold packages whose commands need checking (might differ from package name, e.g., fd-find -> fd)
  local commands_to_check=("${packages[@]}")

  # Special case: if installing fd-find, check for the 'fd' command existence
  local check_pkg check_cmd
  local temp_commands=()
  for pkg in "${commands_to_check[@]}"; do
    if [[ "$pkg" == "fd-find" ]]; then
      temp_commands+=("fd") # Check for 'fd' command
    elif [[ "$pkg" == "ripgrep" ]]; then
      temp_commands+=("rg") # Check for 'rg' command
    else
      temp_commands+=("$pkg") # Default: command name is the same as package name
    fi
  done
  commands_to_check=("${temp_commands[@]}")

  # Loop through each package name provided
  for i in "${!packages[@]}"; do
    check_pkg="${packages[$i]}"
    check_cmd="${commands_to_check[$i]}"
    # Check if the command associated with the package exists
    if ! command_exists "$check_cmd"; then
      # If not found, add the *package name* to the list of missing packages
      missing_packages+=("$check_pkg")
    fi
  done # End of the for loop

  # Check if the missing_packages array has any elements
  if [ ${#missing_packages[@]} -gt 0 ]; then
    # If there are missing packages, print a message and install them
    echo "Installing missing packages: ${missing_packages[*]}..."
    # Update package lists first (redundant if run just before, but safe)
    # sudo apt update
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
  local target_dir="$HOME"             # Default target for stow is HOME

  echo "Cleaning up potential conflicting symlinks for '$package' in '$target_dir'..."

  # Check if the source directory for the stow package exists within .dotfiles
  if [ ! -d "$dotfiles_dir/$package" ]; then
    echo "Warning: Stow package directory '$dotfiles_dir/$package' not found. Skipping cleanup for '$package'."
    return 0 # Exit the function successfully; not finding the source isn't an error here
  fi

  # Use stow itself to find conflicts and potentially remove links it owns
  # Stow -D will delete links it created for the package in the target dir
  echo "  Attempting to unstow '$package' first to remove known links..."
  ( # Run in subshell to manage directory changes
    cd "$dotfiles_dir" || return 1 # Need to be in parent of package dir
    # Use stow's delete (-D) option. Target (-t) is HOME. Verbose (-v).
    # Ignore errors (|| true) because it might fail if links don't exist or target dir isn't set up yet.
    stow -v -D -t "$target_dir" "$package" || true
  )

  # Optional: Add manual check for remaining items if stow -D isn't sufficient
  # (The previous manual find logic could be re-added here if needed, but stow -D is preferred)

} # End of cleanup_stow_symlinks function

echo "Starting installation script..."

# Check for essential tools needed by the script itself and for PPA management
install_if_missing stow git curl software-properties-common

# Update package lists - good practice before installing anything
echo "Updating package lists..."
sudo apt update

# Install core system packages frequently used in development setups
echo "Installing core system packages (zsh, tmux, fzf, ripgrep, fd-find)..."
# Pass package names; the function checks corresponding commands (e.g., rg for ripgrep, fd for fd-find)
install_if_missing zsh tmux fzf ripgrep fd-find

# Optional: Create a symlink for fd-find to be called as fd if fd-find installed but fd doesn't exist
if command_exists fdfind && ! command_exists fd; then
  echo "Creating symlink for 'fd' command pointing to 'fdfind'..."
  FDFIND_PATH=$(command -v fdfind)
  if [ -n "$FDFIND_PATH" ]; then
    # Check if symlink already exists before creating
    if [ ! -L /usr/local/bin/fd ]; then
      sudo ln -s "$FDFIND_PATH" /usr/local/bin/fd || echo "Warning: Failed to create symlink for fd. Manual creation might be needed."
    else
      echo "Symlink /usr/local/bin/fd already exists."
    fi
  else
    echo "Warning: Could not find fdfind path to create symlink."
  fi
fi

# Install Fastfetch using its PPA
echo "Checking/Installing Fastfetch..."
if ! command_exists fastfetch; then
  echo "Fastfetch not found. Installing via PPA..."
  # Add the PPA non-interactively
  sudo add-apt-repository ppa:zhangsongcui3371/fastfetch -y
  # Update package lists after adding the PPA
  sudo apt update
  # Install fastfetch
  sudo apt install -y fastfetch
  echo "Fastfetch installed successfully."
else
  echo "Fastfetch is already installed."
fi

# Install Oh My Zsh if the installation directory doesn't exist
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  # Use the official installation command, running unattended to avoid prompts
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "Oh My Zsh is already installed."
fi

# Install ASDF version manager
ASDF_DIR="$HOME/.asdf"
ASDF_VERSION="v0.16.0" # Specify desired ASDF version tag (Consider using latest stable)

# Check if ASDF command is already available
if command_exists asdf; then
  echo "ASDF command found. Assuming ASDF is already installed and sourced."
# Check if the ASDF directory exists, even if the command isn't sourced in the current (script's) shell
elif [ -d "$ASDF_DIR" ]; then
  echo "ASDF directory ($ASDF_DIR) found, but 'asdf' command not in PATH/sourced for this script."
  echo "Assuming ASDF is installed but needs sourcing setup."
  # Ensure sourcing lines are present in ~/.zshrc
  echo "Ensuring ASDF sourcing lines are in ~/.zshrc..."
  # Check/add main asdf.sh sourcing line
  if ! grep -Fxq ". \"\$ASDF_DIR/asdf.sh\"" ~/.zshrc; then
    echo '# ASDF Setup' >>~/.zshrc
    echo ". \"\$ASDF_DIR/asdf.sh\"" >>~/.zshrc
  fi
  # Check/add completions sourcing line
  if ! grep -Fxq ". \"\$ASDF_DIR/completions/asdf.bash\"" ~/.zshrc; then
    echo ". \"\$ASDF_DIR/completions/asdf.bash\"" >>~/.zshrc
  fi

  echo "Attempting to source ~/.zshrc to make 'asdf' command available within the script..."
  # Source the file in the current script's environment.
  # This does NOT affect the parent shell you ran the script from.
  if [ -f ~/.zshrc ]; then
    . ~/.zshrc
  else
    echo "Warning: ~/.zshrc not found, cannot source."
  fi

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
  if ! grep -Fxq ". \"\$ASDF_DIR/asdf.sh\"" ~/.zshrc; then
    echo '# ASDF Setup' >>~/.zshrc
    echo ". \"\$ASDF_DIR/asdf.sh\"" >>~/.zshrc
  fi
  if ! grep -Fxq ". \"\$ASDF_DIR/completions/asdf.bash\"" ~/.zshrc; then
    echo ". \"\$ASDF_DIR/completions/asdf.bash\"" >>~/.zshrc
  fi

  # Source now to make it available for subsequent script steps
  echo "Sourcing ~/.zshrc to make 'asdf' command available..."
  if [ -f ~/.zshrc ]; then
    . ~/.zshrc
  else
    echo "Warning: ~/.zshrc not found, cannot source."
  fi
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
      asdf plugin add neovim || { echo "Error: Failed to add asdf neovim plugin."; }
    else
      echo "ASDF Neovim plugin already added."
    fi

    # Check if the plugin was added successfully before proceeding
    if asdf plugin list | grep -q "neovim"; then
      # Find the latest stable version offered by the plugin
      # Filter out non-release versions and get the last one (usually latest)
      LATEST_NEOVIM=$(asdf list-all neovim | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | tail -n 1)

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
  fi
else
  echo "ASDF command not found. Cannot install Neovim via ASDF."
fi

# Install Oh My Zsh plugins by cloning their repositories if they don't exist
echo "Checking/Installing Oh My Zsh plugins..."
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}" # Use ZSH_CUSTOM if set, fallback to default
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
# Note: Oh My Zsh handles sourcing for plugins listed in the 'plugins=(...)' array in .zshrc
# Adding it manually is only needed if NOT adding to the OMZ plugins array.
# It's generally better to add 'zsh-syntax-highlighting' to the plugins array in ~/.zshrc.
echo "Checking zsh-syntax-highlighting source line in ~/.zshrc..."
ZSH_SYNTAX_HIGHLIGHTING_PATH="\$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
ZSH_SYNTAX_HIGHLIGHTING_PATH_EXPANDED="$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
if ! grep -q "zsh-syntax-highlighting.zsh" ~/.zshrc; then
  if [ -f "$ZSH_SYNTAX_HIGHLIGHTING_PATH_EXPANDED" ]; then
    echo "Adding manual source line for zsh-syntax-highlighting to ~/.zshrc (consider adding to OMZ plugins array instead)."
    echo "" >>~/.zshrc
    echo '# Zsh Syntax Highlighting Setup (Manual Source - consider adding to OMZ plugins array)' >>~/.zshrc
    echo "source \"$ZSH_SYNTAX_HIGHLIGHTING_PATH\"" >>~/.zshrc
  else
    echo "Warning: zsh-syntax-highlighting plugin file not found at $ZSH_SYNTAX_HIGHLIGHTING_PATH_EXPANDED. Cannot add source line."
  fi
else
  echo "zsh-syntax-highlighting seems to be sourced or added to OMZ plugins array in ~/.zshrc."
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
  STOW_PACKAGES=("nvim" "zsh" "tmux") # Add other package names as needed (e.g., git, bin)

  # Loop through the defined packages
  for package in "${STOW_PACKAGES[@]}"; do
    # Check if a directory for this package actually exists in .dotfiles
    if [ -d "./$package" ]; then
      # Run the cleanup function first to remove potentially conflicting old links using stow -D
      cleanup_stow_symlinks "$package"

      echo "Running stow for package '$package'..."
      # Run stow:
      # -v: verbose
      # -R: restow (relink files, overwriting existing links *from this package*)
      # -t ~: target directory is HOME
      # --no-folding: prevents merging directories (safer)
      stow -v -R -t ~ "$package" --no-folding || {
        echo "Error: Stow command failed for '$package'. Check warnings above. Manual intervention may be needed."
        exit 1
      }
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
echo "IMPORTANT: You MUST restart your terminal or run 'source ~/.zshrc'"
echo "           manually in any open terminals to apply all changes (like ASDF paths, Zsh plugins, and new PATH entries)."
echo "-----------------------------------------------------"
