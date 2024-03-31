if exists("g:loaded_commentator") || v:version < 703
  finish
endif
let g:loaded_commentator = 1

let s:commenttypes = {
	\'c':'\/\/', 'cpp':'\/\/', 'go':'\/\/', 'make':'#',
	\'markdown':'#','php':'#', 'sh':'#', 'vim':'"', 'sql':'--'
\}

function! s:comment(...)
	let l:comstr = s:commenttypes[&ft]
	normal! my
	let l:idx = a:1
	for l:line in getline(a:1,a:2)
		let l:comcom = l:idx.'s/^/'.l:comstr.'/'
		if l:line =~ '^\s*'.l:comstr
			let l:comcom = l:idx.'s/^\s*'.l:comstr.'//'
		endif
		silent! execute l:comcom
		let l:idx += 1
	endfor	
	normal! `y
endfunction

command! -range Comment call s:comment(<line1>,<line2>)
