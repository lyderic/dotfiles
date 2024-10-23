if exists("g:loaded_templates")
	finish
endif
let g:loaded_templates = 1

let s:dir = expand('~/.vim/templates')

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

"Make the current buffer's file executable
function! MakeExecutable()
  let l:file = expand('%:p')
  let l:output = system('chmod -v +x ' . shellescape(l:file))
	echohl WarningMsg
  echo trim(l:output)
	echohl None
endfunction

"Make the current buffer's file unexecutable
function! MakeUnexecutable()
  let l:file = expand('%:p')
  let l:output = system('chmod -v -x ' . shellescape(l:file))
	echohl WarningMsg
  echo trim(l:output)
	echohl None
endfunction

command! Templates call Templates()
command! MakeExecutable call MakeExecutable()
nnoremap <silent> <leader>t :call Templates()<cr>
nnoremap <silent> <leader>k :call MakeExecutable()<cr>
nnoremap <silent> <leader>K :call MakeUnexecutable()<cr>
