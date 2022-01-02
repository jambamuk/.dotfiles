source ~/.config/nvim/vim/plugins.vim
source ~/.config/nvim/vim/sets.vim
source ~/.config/nvim/vim/theme.vim
source ~/.config/nvim/vim/mappings.vim

lua << EOF
require('imtiaz.lsp')
require('imtiaz.treesitter')
EOF
