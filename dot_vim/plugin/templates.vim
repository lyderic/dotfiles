if exists("g:loaded_templates")
	finish
endif
let g:loaded_templates = 1

let s:dir = expand('~/.vim/templates')

function! TemplateComplete(A, L, P)
	return map(globpath('~/.vim/templates', a:A . '*', 0, 1),
		\ 'fnamemodify(v:val, ":t")')
endfunction

function! Templates()
	call s:InsertTemplateFromFZF()
endfunction

function! s:InsertTemplateFromFZF()
	let l:header = '"Please select a template:"'
	let l:preview = 
		\ printf('"bat --color=always --tabs=2 %s/{}"', s:dir)
	call fzf#run({
		\ 'source': 'ls ' . s:dir, 
		\ 'sink': function('s:InsertTemplate'), 
		\ 'options': printf('--reverse --header %s --preview %s', l:header, l:preview)
		\ })
endfunction

function! s:InsertTemplate(file)
	let l:curpos = getpos('.')
	execute "read " . s:dir . "/" . a:file
	" we don't want no first line empty
	if empty(getline(1))
		silent! execute "1d"
	endif
	call setpos('.', l:curpos)
endfunction

"Toggle the current buffer's file executable status
function! ToggleExecutable()
	let l:file = expand('%:p')
	if empty(l:file)
		echohl ErrorMsg | echo "Buffer has no name, cannot save" | echohl None
		return
	endif
	if &modified
		write
	endif
	let l:flag = executable(l:file) ? '-x' : '+x'
	let l:output = system('chmod -v ' . l:flag . ' ' . shellescape(l:file))
	if v:shell_error
		echohl ErrorMsg
	else
		echohl WarningMsg
	endif
	echo trim(l:output)
	echohl None
endfunction

command! -nargs=1 -complete=customlist,TemplateComplete Template 0r ~/.vim/templates/<args>
command! SelectTemplate call Templates()
command! ToggleExecutable call ToggleExecutable()
nnoremap <silent> <leader>t :call Templates()<cr>
nnoremap <silent> <leader>k :call ToggleExecutable()<cr>
