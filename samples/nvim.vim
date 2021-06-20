" nvim init file

" Configure directories used by nvim
set undofile
set backup
let &directory = expand('~/.cache/nvim/swap//')
let &backupdir = expand('~/.cache/nvim/backup//')
let &undodir   = expand('~/.cache/nvim/undo//')

" Create directories and set their permissions
if !isdirectory(&directory) | call mkdir(&directory, "p", "0700") | endif
if !isdirectory(&backupdir) | call mkdir(&backupdir, "p", "0700") | endif
if !isdirectory(&undodir)   | call mkdir(&undodir, "p", "0700")   | endif

" Configure shared data file
let &shada = expand('~/.cache/nvim/shada')
let &shadafile = expand('~/.cache/nvim/shada/main.shada')

" Editor settings:
set tabstop=3
set shiftwidth=0
"set expandtab
set number
set nowrap
set guicursor=
set scrolloff=5

" Vertical split
hi clear VertSplit
hi VertSplit ctermbg=234 ctermfg=250
set fillchars+=vert:\│

" Statusline
hi clear StatusLine
hi clear StatusLineNC
hi StatusLine   term=bold cterm=bold gui=bold ctermbg=234 guibg=DarkGrey
hi StatusMode   term=bold cterm=bold gui=bold ctermbg=234 guibg=DarkGrey ctermfg=34
hi StatusLineNC ctermbg=232 guibg=DarkGrey
if $USER == 'root' | hi Statusline ctermfg=124 | else | hi Statusline ctermfg=15 | endif

let g:currentmode={
	\ 'n' : 'NORMAL',
	\ 'v' : 'VISUAL',
	\ 'V' : 'V-LINE',
	\ '': 'V-BLOCK',
	\ 's' : 'SELECT',
	\ 'S' : 'S-LINE',
	\ '': 'S-BLOCK',
	\ 'i' : 'INSERT',
	\ 'R' : 'REPLACE',
	\ 'Rv': 'V-REPLACE',
	\ 'c' : 'COMMAND',
	\}

" Dinamically set the statusline based on active/inactive split.
augroup statusline
	autocmd!
	autocmd WinEnter,BufEnter * setlocal statusline=%#StatusMode#\ %{g:currentmode[mode()]}\ »%#StatusLine#\ %t:\ %l:%c\ /\ %L%=%r\ %y\ %p%%\ 
	autocmd WinLeave,BufLeave * setlocal statusline=%#StatusLineNC#\ %t%=%r\ %y\ %p%%\ 
augroup end

" Cursor line:
hi clear CursorLine
hi CursorLine   ctermbg=233 guibg=DarkGrey
hi clear CursorLineNr
hi CursorLineNr ctermbg=233 guibg=DarkGrey ctermfg=11 gui=bold guifg=Yellow
set cursorline

" Tabline
hi clear TabLine
hi TabLine ctermfg=15 ctermbg=234 guifg=White guibg=DarkGrey
hi clear TabLineFill
hi TabLineFill ctermfg=0 ctermbg=234 guibg=DarkGrey
hi clear TabLineSel
hi TabLineSel cterm=bold ctermfg=15 ctermbg=237 guibg=Grey
