"Litt help
"appended to existing g:lkhelp variable
"that is defined in ~/.vimrc
let b:lklitthelp = g:lkhelp + [
	\g:lkhelpseparator,
	\'Litt',
	\g:lkhelpseparator,
	\g:mapleader.'o  toggle Goyo',
	\g:mapleader.'f  fix typo',
	\g:mapleader.'e  add to dictionnary',
	\g:mapleader.'re launch Quickfix revision',
	\g:mapleader.'d  delete revision',
	\'(in insert mode) [[[ create a new revision',
	\g:lkhelpseparator,
	\'Note: More about litt: :help litt',
	\g:lkhelpseparator,
\]
function! LeaderLittHelp()
	echo join(b:lklitthelp, "\n")
endfunction
command! LeaderLittHelp :call LeaderLittHelp()
nnoremap <buffer> <leader>h :call LeaderLittHelp()<cr>

