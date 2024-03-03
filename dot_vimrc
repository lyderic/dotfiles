"Lyderic Landry's ViM configuration file

"Required
set nocompatible

"My <leader> key (overwrites \)
let mapleader = '-'

"We always want UTF-8 whenever possible
set encoding=utf-8

"Alternatives to [ESC] in insert mode
inoremap jj <esc>

"[ESC] with simpler saving in insert mode
inoremap jk <esc>:w<cr>

"Simply hitting '=' in normal mode saves the buffer
nnoremap = :w<cr>

"Show buffers to select
nnoremap <leader>p :buffer <C-d>
"nnoremap <leader>p :call fzf#run({'source':GetBuffers(),'sink':'e'})<cr>

"Quicker way to call FZF
nnoremap <leader>z :FZF<cr>

"Quickfix navigation
nnoremap ]q  :cnext<cr>
nnoremap [q  :cprevious<cr>

"ftplugin mechanism
"nice tuto here: https://ejmastnak.github.io/tutorials/vim-latex/ftplugin.html
filetype on          " enable filetype detection
filetype plugin on   " load file-specific plugins
filetype indent on   " load file-specific indentation

"Show italics and bolds nicely when editing markdown
"in normal and command modes
set conceallevel=3
set concealcursor=nc

" In code mode, 'Q' simply shows the registers
nnoremap Q :registers<cr>

"Jump to the last position when reopening a file
autocmd! BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

"Set path conveniently when working on coding or litterary projects
autocmd! VimEnter *.lkl,*.go :set path=**

"Display a statusline even if there is only one widow open
set laststatus=2

"Set up a default statusline
if &statusline == ""
	set statusline+=%f\ %h%m%w%r  "left (f=file,h=help,m=modified,w=preview,r=ro)
	set statusline+=%=            "separator l/r
	set statusline+=%k\ %l,%v\ %P "right (k=keymap,l=line,v=col,P=progress)
endif

"Wrap to the next line without breaking the words
set wrap
set linebreak

"In case of joining lines, no double space after a dot
set nojoinspaces

"Display as much characters that can fit on the line, independently of the
"frame width
set textwidth=0

"Autoindent when return to the next line (useful in programming)
set autoindent

"Helps indenting when writing code
set smartindent

"Autosave current buffer when it is changed to another buffer
set autowriteall

"Show line numbers
set number

"Move easily from one window to another by hitting TAB
nnoremap <tab> <c-w>w

"Scrolling down one page by pressing of [Space]
nnoremap <Space> <PageDown>

"Scrolling up one page by pressing of [Backspace]
map <BS> <PageUp>

"Always show at least one line above/below the cursor
set scrolloff=5

"Default tab for 2
set ts=2

"We now indent with TABs as default as it makes Golang and Makefile happy
"However, YAML doesn't allow tabs as indentation
autocmd! FileType yaml setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
autocmd! BufWritePost *.yaml,*.yml silent! retab | redraw!

"Default backspace like normal
set bs=2

"Some option desactivated by default (remove the no).
set nobackup
set nohlsearch

"Start searching before pressing enter
set incsearch

"Show the position of the cursor.
set ruler

"Show matching parenthese.
set showmatch

"Switch the bells (visual or acoustic) off
set t_vb=
set novisualbell
set noerrorbells

"Show all changes
set report=0

"Open splits right and below
set splitright
set splitbelow

"Show (partial) command keys in the status line
set showcmd

"Supress intro message
set shortmess=I

"Define set list options
set nolist
"For 'lead' listchar, vim 8.2+ required!
set listchars=lead:·,trail:·,tab:--»,nbsp:␣,eol:$
nnoremap <leader>l :set list!<cr>

"Enhanced commandline completion
set wildmenu

"Completion in a pop-up menu (new in vim 9)
set wildoptions=pum

"Better wildmode for selecting buffer
"set wildmode=list,full

"Syntax on by default
syntax on

"Toggle syntax on/off with <leader>x
nnoremap <silent> <leader>x
	\ : if exists("syntax_on") <BAR>
	\    syntax off <BAR>
	\ else <BAR>
	\    syntax enable <BAR>
	\ endif<CR>

"Toggle spellcheck on/off
nnoremap <silent> <leader>xx :let &spell=!&spell<CR>

"Ignore case in searches, unless search contains an upper case letter
set ignorecase
set smartcase

"Set width for autoincrement
set shiftwidth=2

"Don't show @s if the last line does not fit
set display=lastline

"Remap j and k to be usable on long lines
nnoremap j gj
nnoremap k gk

"Quit and save all (same as 'ZZ' but for all buffers)
nnoremap ZA :wqa<cr>

"Quit all without saving (same as 'ZQ' but for all buffers)
nnoremap ZAQ :qa!<cr>

"Command to change the directory to the directory of the current file
command! CurrentDir normal :cd %:h<cr>:pwd<cr>

"UTF-8 non breaking space
inoremap ¬  

"Toggle accents keymap (found in ~/.vim/keymap/lkaccents.vim)
function! ToggleAccents()
	if ! filereadable(expand('~/.vim/keymap/lkaccents.vim'))
		echo "Accents not installed"
		return
	endif
	if &keymap == "lkaccents"
			echo "Accents Off"
			setlocal keymap=
	else
			echo "Accents On"
			setlocal keymap=lkaccents
	endif
endfunction
nnoremap <leader>a :call ToggleAccents()<cr>
nnoremap <c-j> :call ToggleAccents()<cr>
inoremap <c-j> <esc>:call ToggleAccents()<cr>a
inoremap ;; <esc>:call ToggleAccents()<cr>a

"Deal with background
set background=dark
command! Dark set background=dark
command! Light set background=light

"We want .tex files to be always or type latex!
let g:tex_flavor='latex'

"Use as strong encryption as possible
set cryptmethod=blowfish2

"Open terminal to the right (vim 8.1+ required!)
command! VTerm :vertical rightbelow terminal

"----------------------------------------------
"    FUNCTIONS
"----------------------------------------------

"Word completion with [TAB], except when at begining of line
function! SmartTabCompletion()
	let pos = col('.') - 1
	"if pos == 0 || getline('.')[pos - 1] !~ '\k'
	if pos == 0 || getline('.')[pos - 1] =~ '\s'
		return "\<tab>"
	else
		return "\<c-n>"
	endif
endfunction
inoremap <tab> <c-r>=SmartTabCompletion()<cr>

"If a session exists, save it before leaving
"(Only for .lkl, .yaml and .go files)
function! SaveSessionIfFound()
	if !empty(v:this_session)
		echohl WarningMsg
		echo "saving session..."
		mksession!
		sleep 500m
		echohl None
	endif
endfunction
autocmd! VimLeave *.lkl,*.yaml,*.go :call SaveSessionIfFound()

function! ToggleNumber()
	setlocal number!
	if &number == 0
		echo "number disabled"
	else
		echo "number enabled"
	endif
endfunction
nnoremap <leader>n :call ToggleNumber()<cr>

function! ToggleRelativenumber()
	setlocal relativenumber!
	if &relativenumber == 0
		nnoremap <buffer> j gj
		nnoremap <buffer> k gk
		echo "relativenumber disabled"
	else
		nnoremap <buffer> j j
		nnoremap <buffer> k k
		echo "relativenumber enabled"
	endif
endfunction
nnoremap <leader>N :call ToggleRelativenumber()<cr>

function! DisplayInformation()
	let l:u = "unset"
	echo "Path: " . expand('%:p')
		\ "--"
		\ printf("[%s]", (&filetype == ""   ? l:u : &filetype))
		\ printf("[%s]", (&encoding == ""   ? l:u : &encoding))
		\ printf("[%s]", (&fileformat == "" ? l:u : &fileformat))
	let l:chars = ThousandsSeparator(wordcount().chars)
	let l:words = ThousandsSeparator(wordcount().words)
	let l:bytes = ThousandsSeparator(wordcount().bytes)
	let l:fmt = "%4s: %" . strlen(l:bytes) . "s"
	echo printf(l:fmt, "Chars", l:chars)
	echo printf(l:fmt, "Words", l:words)
	echo printf(l:fmt, "Bytes", l:bytes)
endfunction
command! DisplayInformation :call DisplayInformation()
nnoremap <leader>g :call DisplayInformation()<cr>

"Thanks to: https://stackoverflow.com/questions/10461055/how-to-insert-thousand-separators-only-before-the-decimal-separator
function! ThousandsSeparator(input)
	return substitute(a:input, '\(\d,\d*\)\@<!\d\ze\(\d\{3}\)\+\d\@!', '&,', 'g')	
endfunction

let g:lkhelpseparator = 
			\ '===================================================='
let g:lkhelp = [
	\g:lkhelpseparator,
	\'General (leader = ' . g:mapleader . ')',
	\g:lkhelpseparator,
	\g:mapleader.'a  toggle accents',
	\g:mapleader.'c  CountInRange <[line1]> <[line2]>',
	\g:mapleader.'g  show file information',
	\g:mapleader.'l  toggle show hidden characters',
	\g:mapleader.'n  toggle number',
	\g:mapleader.'N  toggle relativenumber',
	\g:mapleader.'p  switch buffer',
	\g:mapleader.'x  switch syntax on/off',
	\g:mapleader.'xx switch French spell checking on/off',
	\g:mapleader.'z  call FZF',
	\'Quickfix Navigation: ]q :cnext, [q :cprevious',
	\'Folds Navigation: za: toggle, [z: start, ]z: end',
\]
function! LeaderHelp()
	echo join(g:lkhelp, "\n")
endfunction
command! LeaderHelp :call LeaderHelp()
nnoremap <leader>h :call LeaderHelp()<cr>

function! CountInRange(arg1 = line('.'), arg2 = line('$'))
	let l:first = a:arg1
	let l:last = a:arg2
	if a:arg1 == "." | let l:first = line('.') | endif
	if a:arg2 == "." | let l:last = line('.') | endif
	if a:arg2 == "$" | let l:last = line('$') | endif
	if a:arg1 == a:arg2
		echon "Count in line " . l:first
	else
		echon "Count in lines " . l:first . "-" . l:last
	endif
	echon " (lines, words, chars):"
	execute l:first.",".l:last."w !wc -lwm"
endfunction
command! -nargs=* CountInRange call CountInRange(<f-args>)

"List all the files found in the buffers list
if !exists("*GetBuffers")
	function! GetBuffers()
		let l:all = range(1, bufnr('$'))
		let listing = []
		for id in l:all
			"buffer must be listed and not be a directory
			if buflisted(id) && ! isdirectory(bufname(id))
				call add(listing, bufname(id))
			endif
		endfor
		return listing
	endfunction
endif
command! -buffer GetBuffers call GetBuffers()
nnoremap <leader>c :CountInRange 
