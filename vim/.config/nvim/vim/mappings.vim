"window
nmap <C-h> :winc h<CR>
nmap <C-j> :winc j<CR>
nmap <C-k> :winc k<CR>
nmap <C-l> :winc l<CR>

"tabs
nmap <C-o> :tabn<CR>
nmap <C-i> :tabp<CR>
nnoremap tn :tabnew<CR>

nnoremap <F2> :NERDTree<CR>

" Saving
noremap <C-w> :TrailerTrim<CR>:wa<CR>
inoremap <C-w> <Esc>:TrailerTrim<CR>:wa<CR>
noremap <C-x> :q<CR>
inoremap <C-x> <Esc>:q<CR>
noremap <C-q> :TrailerTrim<CR>:wq<CR>
inoremap <C-q> <Esc>:TrailerTrim<CR>:wq<CR>

inoremap <Alt-j> <ESC>
inoremap ∆ <ESC>

inoremap <C-j> <Esc>
vnoremap <C-j> <Esc>
map <C-j> <Esc>

let g:AutoPairsShortcutJump = '<C-;>'

" NERDTree
nnoremap <leader>nt :NERDTreeFind<CR>
nnoremap <leader>ig :IndentLinesToggle<CR>

" Git
nnoremap <leader>gb :Gblame<CR>
nnoremap <leader>gg :tab new<CR>:G<CR>:winc j<CR>:q<CR>
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

" EasyMotion
let g:EasyMotion_smartcase = 1
nmap s <Plug>(easymotion-s)
nmap <leader>s <Plug>(AerojumpBolt)
omap <leader>s <Plug>(AerojumpBolt)
map  / <Plug>(easymotion-sn)
omap / <Plug>(easymotion-tn)
