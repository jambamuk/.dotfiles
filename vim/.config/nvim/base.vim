set nocompatible
let mapleader="\<Space>"
let maplocalleader="\<Space>"
filetype plugin on
filetype on
au BufNewFile,BufRead * if &ft == '' | set ft=vim | endif
set clipboard+=unnamed,unnamedplus

set re=1

" Spacing
set expandtab
set tabstop=2
set softtabstop=2
set shiftwidth=2

" Searching
set nohlsearch
"ctrlp
let g:ctrlp_max_files=0
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*/node_modules/*,*/public/*

if has('nvim') || has('termguicolors')
  set termguicolors
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif

set termguicolors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

"auto complete options
set completeopt+=menuone
set completeopt+=noselect
set shortmess+=c

" Easy motion
let g:EasyMotion_smartcase = 1
nmap s <Plug>(easymotion-s)
nmap <leader>s <Plug>(AerojumpBolt)
omap <leader>s <Plug>(AerojumpBolt)
map  / <Plug>(easymotion-sn)
omap / <Plug>(easymotion-tn)
