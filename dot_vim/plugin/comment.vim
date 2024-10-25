if exists("g:loaded_commentator") || v:version < 703
  finish
endif
let g:loaded_commentator = 1

let s:commenttypes = {
\'litt':'\/\/', 'c':'\/\/', 'cpp':'\/\/', 'go':'\/\/', 'make':'#',
\'markdown':'#', 'php':'#', 'sh':'#', 'vim':'"', 'sql':'--',
\'just':'#', 'lua':'--', 'tex':'%'
\}

function! Comment(...)
	if a:0 == 0
		let l:l1 = line(".")
		let l:l2 = l:l1
	else
		let l:l1 = a:1
		let l:l2 = a:2
	endif
	let l:comstr = s:commenttypes[&ft]
	normal! my
	let l:idx = l:l1
	for l:line in getline(l:l1,l:l2)
		let l:comcom = l:idx.'s/\v^(\s*)/\1'.l:comstr.'/'
		if l:line =~ '^\s*'.l:comstr
			let l:comcom = l:idx.'s/\v^(\s*)'.l:comstr.'/\1/'
		endif
		silent! execute l:comcom
		let l:idx += 1
	endfor	
	normal! `y
endfunction

command! -range Comment call Comment(<line1>,<line2>)
nnoremap <leader>m :call Comment()<cr>
