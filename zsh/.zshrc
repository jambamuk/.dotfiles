source ~/.dotfiles/zsh/base.zsh
source ~/.dotfiles/zsh/plugins.zsh
source ~/.dotfiles/zsh/aliases.zsh

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/imtiaz/apps/google-cloud-sdk/path.zsh.inc' ]; then . '/home/imtiaz/apps/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/imtiaz/apps/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/imtiaz/apps/google-cloud-sdk/completion.zsh.inc'; fi
