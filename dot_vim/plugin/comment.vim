if exists("g:loaded_commentator") || v:version < 703
  finish
endif
let g:loaded_commentator = 1

let s:commenttypes = {
	\'c':'\/\/', 'cpp':'\/\/', 'go':'\/\/', 'make':'#',
	\'markdown':'#','php':'#', 'sh':'#', 'vim':'"',
\}

function! s:comment(...)
	normal! my
	let l:idx = a:1
	for l:line in getline(a:1,a:2)
		let l:comcom = l:idx.'s/^/'.s:commenttypes[&ft].'/'
		if l:line =~ '^\s*'.s:commenttypes[&ft]
			let l:comcom = l:idx.'s/^\s*'.s:commenttypes[&ft].'//'
		endif
		silent! execute l:comcom
		let l:idx += 1
	endfor	
	normal! `y
endfunction

command! -range Comment call s:comment(<line1>,<line2>)
