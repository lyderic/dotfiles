function! Template(type)
	if len(a:type) > 0
		exec "read ~/.vim/templates/template." . a:type
	else
		call s:GetTemplateFromFZF()
	endif
	silent! exec "1d"
	norma G
endfunction

function! s:InsertTemplate(file)
	if empty(a:file)
		echo "No template file provided"
	else
		exec "read ~/.vim/templates/" . a:file
	endif
endfunction

function! s:GetTemplateFromFZF()
	call fzf#run({'source': 'ls ~/.vim/templates', 'sink': function('s:InsertTemplate')})
endfunction

"command! -nargs=1 Template call Template("<args>")
command! -nargs=* Template call Template("<args>")
