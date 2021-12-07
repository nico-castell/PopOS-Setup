"  _  _             _                      __ _
" | \| |___ _____ _(_)_ __    __ ___ _ _  / _(_)__ _
" | .` / -_) _ \ V / | '  \  / _/ _ \ ' \|  _| / _` |
" |_|\_\___\___/\_/|_|_|_|_| \__\___/_||_|_| |_\__, |
"                                              |___/
" ~/.config/nvim/init.vim

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

" Remember last cursor position
autocmd BufReadPost *
  \ if line("'\"") >= 1 && line("'\"") <= line("$") |
  \   exe "normal! g`\"" |
  \ endif

" Text width settings
hi clear ColorColumn
hi ColorColumn ctermbg=237 guibg=Grey23
augroup vimrcEx
	au!
	autocmd FileType *         setlocal textwidth=0 colorcolumn=0 tabstop=3
	autocmd FileType gitcommit setlocal textwidth=70 colorcolumn=50,70
	autocmd FileType text      setlocal textwidth=100 colorcolumn=100
	autocmd FileType markdown  setlocal textwidth=100 colorcolumn=100
	autocmd FileType limits    setlocal tabstop=8
augroup END

" Editor settings:
set shiftwidth=0
"set expandtab
set number
set nowrap
set guicursor=
set scrolloff=5

" Vertical split
hi clear VertSplit
hi VertSplit ctermbg=232 ctermfg=245 guibg=Grey3 guifg=Grey54
set fillchars+=vert:\│

" Statusline
hi clear StatusLine
hi clear StatusLineNC
hi StatusLine   term=bold cterm=bold gui=bold ctermbg=234 guibg=Grey11
hi StatusLineNC ctermbg=232 guibg=Grey3
if $USER == 'root'
	hi StatusMode  term=bold cterm=bold gui=bold  ctermfg=15 guifg=White  ctermbg=124 guibg=Red3
else
	hi StatusMode  term=bold cterm=bold gui=bold  ctermfg=15 guifg=White  ctermbg=21  guibg=Blue1
endif

let g:currentmode={
	\ 'n' : 'NORMAL',
	\ 'v' : 'VISUAL',
	\ 'V' : 'V-LINE',
	\ '': 'V-BLOCK',
	\ 's' : 'SELECT',
	\ 'S' : 'S-LINE',
	\ '': 'S-BLOCK',
	\ 'i' : 'INSERT',
	\ 'r' : 'HIT-ENTER',
	\ 'R' : 'REPLACE',
	\ 'Rv': 'V-REPLACE',
	\ 'c' : 'COMMAND',
	\ 't' : 'TERMINAL',
	\}

function! PrepInfo()
	let l:full_info = ""
	if strlen(&filetype) > 0     | let l:full_info = l:full_info . &filetype . "|"     | endif
	if strlen(&fileencoding) > 0 | let l:full_info = l:full_info . &fileencoding . "|" | endif
	if strlen(&ff) > 0           | let l:full_info = l:full_info . &ff                 | endif
	return l:full_info
endfunction

" Dinamically set the statusline based on active/inactive split.
augroup statusline
	autocmd!
	autocmd WinEnter,BufEnter * setlocal statusline=%#StatusMode#\ %{g:currentmode[mode()]}\ %#StatusLine#\ %t\ %M%=%r\ %l:%c/%L\ %{PrepInfo()}\ %p%%\ 
	autocmd WinLeave,BufLeave * setlocal statusline=%#StatusLineNC#\ %t\ %M%=%R\ %L\ %p%%\ 
augroup end

" The custom statusline shows the current mode, hide it from command line to avoid redundancy.
set noshowmode

" Use system clipboard
set clipboard+=unnamedplus

" Cursor line:
hi clear CursorLine
hi clear CursorLineNr
hi CursorLine   ctermbg=233 guibg=DarkGrey
hi CursorLineNr ctermbg=233 guibg=DarkGrey ctermfg=11 gui=bold guifg=Yellow
set cursorline

" Folds
hi clear Folded
hi Folded ctermfg=13 ctermbg=235 guifg=Fuchsia guibg=Grey15
set fillchars+=fold:═

" Tabline
hi clear TabLine
hi clear TabLineFill
hi clear TabLineSel
hi TabLine ctermfg=15 ctermbg=232 guifg=White guibg=Grey3
hi TabLineFill ctermfg=0 ctermbg=232 guibg=Grey3
hi TabLineSel cterm=bold ctermfg=15 ctermbg=234 guibg=Grey11
