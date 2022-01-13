source ~/.config/nvim/vim/plugins.vim
source ~/.config/nvim/vim/sets.vim
source ~/.config/nvim/vim/theme.vim
source ~/.config/nvim/vim/mappings.vim

lua << EOF
require('jamba.lsp')
require('jamba.treesitter')
require('jamba.indent-line')
EOF
