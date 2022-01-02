let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
let &t_SR = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=2\x7\<Esc>\\"
let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"

augroup nord-theme-overrides
    autocmd!
       autocmd ColorScheme nord highlight jsxPunct ctermfg=14 guifg=#D8DEE9
       autocmd ColorScheme nord highlight jsxCloseString ctermfg=14 guifg=#D8DEE9
       autocmd ColorScheme nord highlight jsxTagName ctermfg=14 guifg=#8FBCBB
       hi IndentGuidesOdd  guibg='#323845'   ctermbg=3
       hi IndentGuidesEven  guibg='#2C323D'   ctermbg=3
       hi SearchResult  guibg=#EBCB8B ctermfg=White guifg=#D8DEE9
       hi SearchHighlight guibg=#BF616A ctermfg=White guifg=#D8DEE9
augroup END

colorscheme nord
hi SearchResult  guibg=#EBCB8B ctermfg=White guifg=#D8DEE9
hi SearchHighlight guibg=#BF616A ctermfg=White guifg=#D8DEE9

let g:nord_italic = 1
let g:nord_underline = 1
let g:nord_italic_comments = 1
let g:nord_uniform_status_lines = 1
let g:nord_cursor_line_number_background = 1
set guicursor=i:ver25-iCursor
let g:indentLine_enabled = 0

let g:javascript_plugin_jsdoc = 1

"Syntax highlights
syntax keyword componentDocTag /@component/

"File mappings
"
"set filetypes as typescript.tsx
"autocmd BufNewFile,BufRead *.tsx, set filetype=typescript.tsx
"autocmd BufNewFile,BufRead *.jsx, set filetype=typescript.tsx
