setlocal keymap=lkaccents

inoremap <buffer> << «
inoremap <buffer> >> »
inoremap <buffer> __  

function Todoformat()
	normal! my
	silent! %s/\v^(\a) /(\u\1) /
	silent! %s/\v^\((\a)\) /(\u\1) /
	sort
	normal! `y
endfunction
command! Todoformat call Todoformat()
