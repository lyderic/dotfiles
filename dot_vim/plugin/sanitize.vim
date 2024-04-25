"This set of substitution aims at enforcing French language typography rules
"In the comments, 'nbsp' means non-breaking space (Hex 00A0)
"
"Ref: https://www.edithetnous.com/blog/les-10-regles-de-typographie-a-connaitre

if exists("g:loaded_sanitizer") || v:version < 703
  finish
endif
let g:loaded_sanitizer = 1

function Sanitize(...)
	"This is only allowed in markdown files written in French
	"i.e. filetypes 'markdown' and 'litt'
	if (&ft != "markdown" && &ft != "litt")
		echo "Sanitizing only allowed for 'markdown' and 'litt' filetypes!"
		return
	endif
	"This is the default, to which '*' is added (because of markdown's bold)
	setlocal iskeyword=@,48-57,_,192-255,#,*
	"This sets a 'y' mark to go back to when all substitutions have been done
	"(see below: `y)
	normal! my
	let r = a:1.','.a:2
	call s:firstpass(r)
	"The second pass deals with special cases in order to fix the
	"changes introduced by the first pass
	call s:secondpass(r)
	normal! `y
endfunction

function s:firstpass(r)
	"Separator normalization
	silent! execute a:r.'s/^---$/* * */g'
	silent! execute a:r.'s/\*\*\*/* * */g'
	"tiret quadratin (0x2014)
	silent! execute a:r.'s/--/—/g'
	"UTF-8 3-dots (0x2026)
	silent! execute a:r.'s/\.\.\./…/g'
	"French quotes
	silent! execute a:r.'s/\v"(.{-})"/« \1 »/g'
	"nbsp before double punctuation (between 'iskeyword' and ?!;:%€)
	silent! execute a:r.'s/\v(\k)\s*([?!;:%€])/\1 \2/g'
	"nbsp before » (between 'iskeyword' or punctuation and »)
	silent! execute a:r.'s/\v(\k|[.?!])\s*»/\1 »/g'
	"space after some punctuation (between ?!;:», and a letter)
	"note: we don't include '.' otherwise URLs e.g. 'a.b.com' would
	"become 'a. b. com'
	silent! execute a:r.'s/\v([?!;:»,])(\K)/\1 \2/g'
	"nbsp after dialog quadratin at beginning of line
	silent! execute a:r.'s/\v^—\s*(.)/— \1/'
	"nbsp after/before — (ignoring at beginning of line)
	silent! execute a:r.'s/\v(\k)\s*—\s*(.{-})\s*—\s*(\k)/\1 — \2 — \3/g'
	"nbsp after « (between « and 'iskeyword')
	silent! execute a:r.'s/\v«\s*(\k)/« \1/g'
	"space before « (between 'iskeyword' and «)
	silent! execute a:r.'s/\v(\k)\s*«/\1 «/g'
	"Allow https URLs, useful for various notes
	silent! execute a:r.'s#https ://#https://#g'
	"remove trailing whitespaces
	silent! execute a:r.'s/\v\s+$//'
	"remove multiple whitespaces between words
	silent! execute a:r.'s/\v\s+/ /g'
	"remove trailing non-breaking spaces
	silent! execute a:r.'s/\v +$//'
	"remove multiple non-breaking spaces
	silent! execute a:r.'s/\v +/ /g'
endfunction

function s:secondpass(r)
	"Allow time stamp like '12:34' or '12:34:56' e.g. in journal
	silent! execute a:r.'s/\v([0-2][0-9]) :\s*([0-5][0-9])/\1:\2/'
	silent! execute a:r.'s/\v([0-2][0-9]):\s*([0-5][0-9]) :\s*([0-5][0-9])/\1:\2:\3/'
	"space between » and ?!;:
	"e.g. foo »bar becomes: foo » bar
	silent! execute a:r.'s/\v»\s*([?!;:])/» \1/g'
	"space between ?!;: and « 
	"e.g. foo ?« becomes: foo ? «
	silent! execute a:r.'s/\v([?!;:])\s*«/\1 «/g'
endfunction
command! -range Sanitize call Sanitize(<line1>,<line2>)

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Notes:
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" \v: set 'magic' flag : avoids many \-escapes
" \k: anything that is defined in 'iskeyword'
" \K: like \k, but excluding digits
" \S: anything but ' ' or '\t'
"
" UTF-8 characters used here:
"  — : tiret quadratin (0x2014)
"  … : 3-dots (0x2026)
"    : non-breaking space (0x00A0)
