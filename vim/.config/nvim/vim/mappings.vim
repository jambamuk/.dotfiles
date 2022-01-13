"window
nmap <C-h> :winc h<CR>
nmap <C-j> :winc j<CR>
nmap <C-k> :winc k<CR>
nmap <C-l> :winc l<CR>

"tabs
nmap <C-i> :tabn<CR>
nmap <C-y> :tabp<CR>
nnoremap tn :tabnew<CR>

nnoremap <F2> :NERDTree<CR>

" Saving
noremap <C-s> :TrailerTrim<CR>:wa<CR>
inoremap <C-s> <Esc>:TrailerTrim<CR>:wa<CR>
noremap <C-x> :q<CR>
inoremap <C-x> <Esc>:q<CR>
noremap <C-q> :TrailerTrim<CR>:wq<CR>
inoremap <C-q> <Esc>:TrailerTrim<CR>:wq<CR>

inoremap jk <Esc>

let g:AutoPairsShortcutJump = '<C-;>'
" git
nnoremap <leader>gb :Gblame<CR>
nnoremap <leader>gg :tab new<CR>:G<CR>:winc j<CR>:q<CR>G

" Using Lua functions
nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>
nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>

" GOYO
function! s:goyo_enter()
  Goyo 85%x85%
  set showmode
  set showcmd
  GitGutterEnable
endfunction

function! s:goyo_leave()
endfunction

nnoremap <leader>y :Goyo<CR>
autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()

" Syntax highlighting
function! SynStack ()
  for i1 in synstack(line("."), col("."))
    let i2 = synIDtrans(i1)
    let n1 = synIDattr(i1, "name")
    let n2 = synIDattr(i2, "name")
    echo n1 "->" n2
  endfor
endfunction
map ch :call SynStack()<CR>

