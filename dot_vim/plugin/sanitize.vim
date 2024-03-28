"This set of substitution aims at enforcing French language typography rules
"In the comments, 'nbsp' means non-breaking space (Hex 00A0)
"
"Ref: https://www.edithetnous.com/blog/les-10-regles-de-typographie-a-connaitre

function Sanitize()
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
	call SanitizeFirstPass()
	"The second pass deals with special cases in order to fix the
	"changes introduced by the first pass
	call SanitizeSecondPass()
	normal! `y
endfunction
function SanitizeFirstPass()
	"Separator normalization
	silent! %s/^---$/* * */g 
	silent! %s/\*\*\*/* * */g
	"UTF-8 representations
	silent! %s/--/—/g "tiret quadratin (0x2014)
	silent! %s/\.\.\./…/g "UTF-8 3-dots (0x2026)
	"French quotes
	silent! %s/\v"(.{-})"/« \1 »/g
	"nbsp before double punctuation (between 'iskeyword' and ?!;:»)
	silent! %s/\v([A-Za-z0-9.])\s*([?!;:»])/\1 \2/g
	"space after some punctuation (between ?!;:», and a letter)
	"note: we exclude '.' because of the URLs e.g. 'lyderic.com' would
	"become 'lyderic. com'
	silent! %s/\v([?!;:»,])([A-Za-z])/\1 \2/g
	"nbsp after dialog quadratin at beginning of line
	silent! %s/\v^—\s*(.)/— \1/
	"nbsp after/before — (ignoring at beginning of line)
	silent! %s/\v(\k)\s*—\s*(.{-})\s*—\s*(\k)/\1 — \2 — \3/g
	"nbsp after « (between « and 'iskeyword')
	silent! %s/\v«\s*(\k)/« \1/g
	"space before « (between 'iskeyword' and «)
	silent! %s/\v(\k)\s*«/\1 «/g
	"Allow https URLs, useful for various notes
	silent! %s#https ://#https://#g
	"Remove unwanted whitespaces
	silent! %s/\s\+$//  "remove trailing whitespaces
	silent! %s/\s\+/ /g "remove multiple whitespaces between words
	silent! %s/ \+$//   "remove trailing non-breaking spaces
	silent! %s/ \+/ /g  "remove multiple non-breaking spaces
endfunction
function SanitizeSecondPass()
	"Allow time stamp like '12:34' or '12:34:56' e.g. in journal
	silent! %s/\v([0-2][0-9]) :\s*([0-5][0-9])/\1:\2/
	silent! %s/\v([0-2][0-9]):\s*([0-5][0-9]) :\s*([0-5][0-9])/\1:\2:\3/
	"space between » and ?!;:
	silent! %s/\v»\s*([?!;:])/» \1/g
	"space between ?!;: and « 
	silent! %s/\v([?!;:])\s*«/\1 «/g
endfunction
command! Sanitize call Sanitize()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Notes:
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" \v: set 'magic' flag : avoids many \-escapes
" \k: anything that is defined in 'iskeyword'
" \K: like \k, but excluding digits
" \S: anything but ' ' or '\t'
"
" UTF-8 characters used here:
"  — : tiret quadratin (0x2014)
"  … : 3-dots (0x2026)
"    : non-breaking space (0x00A0)
