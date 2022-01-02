filetype on
filetype plugin on
filetype indent on
syntax on

setlocal spell spelllang=en

set nospell
set relativenumber
set number

set nocompatible
let mapleader="\<Space>"
let maplocalleader="\<Space>"
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
