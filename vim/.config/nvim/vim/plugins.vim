if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
set nocompatible

call plug#begin('~/.vim/bundle')

" Base
Plug 'tpope/vim-fugitive'
Plug 'csexton/trailertrash.vim'
Plug 'tpope/vim-sensible'
Plug 'airblade/vim-gitgutter'
Plug 'preservim/nerdcommenter'
Plug 'powerline/powerline-fonts'

" Code editing
Plug 'junegunn/goyo.vim'
Plug 'tpope/vim-surround'
Plug 'jiangmiao/auto-pairs'
Plug 'alvan/vim-closetag'
Plug 'plasticboy/vim-markdown'
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'mbbill/undotree'

" Navigation
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'christoomey/vim-tmux-navigator'

" LSP
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/nvim-lsp-installer'
Plug 'L3MON4D3/LuaSnip'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-cmdline'
Plug 'onsails/lspkind-nvim' " vscode-like pictograms for autocomplete menu
Plug 'folke/lsp-colors.nvim'
Plug 'mfussenegger/nvim-jdtls' " Java

" Treesitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/nvim-treesitter-textobjects'
Plug 'RRethy/nvim-treesitter-textsubjects'

" Theme
Plug 'arcticicestudio/nord-vim'
Plug 'Mofiqul/vscode.nvim'
call plug#end()

"goyo config
let g:goyo_height=100
let g:goyo_width=100
let g:goyo_linenr=1
