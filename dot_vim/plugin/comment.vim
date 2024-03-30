"if exists("g:loaded_commentator") || v:version < 703
"  finish
"endif
"let g:loaded_commentator = 1

let s:commenttypes = {
	\'c':'\/\/', 'cpp':'\/\/', 'go':'\/\/', 'make':'#',
	\'markdown':'#','php':'#', 'sh':'#', 'vim':'"',
\}

function! s:comment(...)
	normal! my
	let r = a:1.','.a:2
	silent! execute r.'s/^/'.s:commenttypes[&ft].'/'
	normal! `y
endfunction

function! s:uncomment(...)
	normal! my
	let r = a:1.','.a:2
	silent! execute r.'s/^\s*'.s:commenttypes[&ft].'//'
	normal! `y
endfunction

function! s:togglecomment(...)
	normal! my
	let l:idx = a:1
	for l:line in getline(a:1,a:2)
		if s:startswith(l:line,s:commenttypes[&ft])
			"execute l:idx.'s/^\s*'.s:commenttypes[&ft].'//'
			echo "commented"
		else
			echo "uncommented"
		endif
		let l:idx += 1
	endfor	
	normal! `y
endfunction

function! s:startswith(longer, shorter) abort
  return a:longer[0:len(a:shorter)-1] ==# a:shorter
endfunction

command! -range Comment call s:comment(<line1>,<line2>)
command! -range Uncomment call s:uncomment(<line1>,<line2>)
command! -range Togglecomment call s:togglecomment(<line1>,<line2>)
