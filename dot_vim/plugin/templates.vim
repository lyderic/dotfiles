function! Template(type)
	exec "0read ~/.vim/templates/template." . a:type
endfunction
command! -nargs=1 Template call Template("<args>")
