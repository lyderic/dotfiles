"Golang help
"appended to existing g:lkhelp variable
"that is defined in ~/.vimrc
let b:lkgohelp = g:lkhelp + [
	\g:lkhelpseparator,
	\'Golang',
	\g:lkhelpseparator,
	\g:mapleader.'i  run goimport in buffer',
	\':Gomain  insert basic Go template to get started',
	\':ImportTools  add github.com/lyderic/tools',
	\':RemoveTools  remove github.com/lyderic/tools',
	\g:lkhelpseparator,
\]
function! LeaderGoHelp()
	echo join(b:lkgohelp, "\n")
endfunction
command! LeaderGoHelp :call LeaderGoHelp()
nnoremap <buffer> <leader>h :call LeaderGoHelp()<cr>

