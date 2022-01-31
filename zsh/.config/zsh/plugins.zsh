source ~/.config/zsh/antigen.zsh

antigen use oh-my-zsh

plugins=(git reminder osx vi-mode zsh-autosuggestions)
antigen bundle git
antigen bundle AlexisBRENON/oh-my-zsh-reminder
antigen bundle vi-mode
antigen bundle asdf
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle djui/alias-tips
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle unixorn/autoupdate-antigen.zshplugin
antigen bundle supercrabtree/k
antigen bundle jeffreytse/zsh-vi-mode

antigen theme TyWR/Nord-zsh

antigen apply
