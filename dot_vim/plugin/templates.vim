if exists("g:loaded_templates")
	finish
endif
let g:loaded_templates = 1

function! Template()
	call s:InsertTemplateFromFZF()
endfunction

function! s:InsertTemplateFromFZF()
	call fzf#run({'source': 'ls ~/.vim/templates', 'sink': function('s:InsertTemplate'), 'options': '--preview "bat --plain --color=always --tabs=2 ~/.vim/templates/{}"'})
endfunction

function! s:InsertTemplate(file)
	let l:curpos = getpos('.')
	execute "read ~/.vim/templates/" . a:file
	" we don't want no first line empty
	if empty(getline(1))
		silent! execute "1d"
	endif
	call setpos('.', l:curpos)
endfunction

command! Template call Template()
