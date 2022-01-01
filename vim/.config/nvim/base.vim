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

"let g:closetag_filenames = "*.html,*.xhtml,*.phtml,*.php,*.jsx"
"let g:closetag_xhtml_filenames = '*.xhtml,*.jsx'
"let g:closetag_filetypes = 'html,xhtml,phtml'
"let g:closetag_xhtml_filetypes = 'xhtml,jsx'
"let g:closetag_emptyTags_caseSensitive = 1
"let g:closetag_regions = {'typescript.tsx': 'jsxRegion,tsxRegion','javascript.jsx': 'jsxRegion'}
"let g:closetag_shortcut = '>'

" ALE
"let g:ale_completion_tsserver_autoimport = 1
"let g:ale_linters = {
"\   'javascript': ['standard'],
"\   'typescript': ['standard'],
"\   'tsx': ['standard'],
"\   'ts': ['standard'],
"\   'd.ts': ['standard'],
"\}
"let g:coc_filetype_map = {
"\ 'sass': 'scss',
"\}
"let g:ale_fixers = {
"\   'javascript': ['standard'],
"\   'typescript': ['standard'],
"\   'tsx': ['standard'],
"\   'jsx': ['standard'],
"\   'javascriptreact': ['standard'],
"\   'ts': ['standard'],
"\   'd.ts': ['standard'],
"\}
"let g:ale_javascript_standard_options = "--env jest --env mocha --global cy --global Sentry"
"let g:ale_typescript_standard_executable = 'standardx'

"let g:ale_typescript_standard_options = "--parser @typescript-eslint/parser --plugin @typescript-eslint/eslint-plugin --env jest --env mocha --global cy --global Sentry -v"

" Easy motion
let g:EasyMotion_smartcase = 1
nmap s <Plug>(easymotion-s)
nmap <leader>s <Plug>(AerojumpBolt)
omap <leader>s <Plug>(AerojumpBolt)
map  / <Plug>(easymotion-sn)
omap / <Plug>(easymotion-tn)

"COC
"nmap <silent> gd <Plug>(coc-definition)
"nmap <silent> gy <Plug>(coc-type-definition)
"nmap <silent> gi <Plug>(coc-implementation)
"nmap <silent> gr <Plug>(coc-references)
