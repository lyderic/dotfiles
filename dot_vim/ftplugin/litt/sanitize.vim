function Sanitize()
	"This is the default, to which '*' is added (because of markdown's bold)
	setlocal iskeyword=@,48-57,_,192-255,#,*
	"This sets a 'y' mark to go back to when all substitutions have been done
	"(see below: `y)
	normal! my
	silent! %s/^---$/* * */g 
	silent! %s/\*\*\*/* * */g
	silent! %s/--/—/g "tiret quadratin (0x2014)
	silent! %s/\.\.\./…/g "UTF-8 3-dots (0x2026)
	"Non-breaking space before double punctuation: ?!;:
	silent! %s/\v(\k)\s*([?!;:])/\1 \2/g
	silent! %s/» :/» :/g
	silent! %s/»:/» :/g
	"Non-breaking spaces after/before — (ignoring at beginning of line)
	silent! %s/\v(\k) — (.{-}) —/\1 — \2 —/g
	"Non-breaking spaces after/before resp. « and »
	silent! %s/\v«\s*(\k)/« \1/g
	silent! %s/\v(.)\s*»/\1 »/g
	"French quotes
	silent! %s/\v"(.{-})"/« \1 »/g
	"Allow time stamp like '12:34' e.g. in journal
	silent! %s/\v([0-2][0-9]) :([0-5][0-9])/\1:\2/
	"Allow https URLs, useful for various notes
	silent! %s#https ://#https://#g
	"Remove unwanted whitespaces
	silent! %s/\s\+$// "remove trailing whitespaces
	silent! %s/\s\+/ /g "remove multiple whitespaces between words
	silent! %s/ \+$// "remove trailing non-breaking spaces
	silent! %s/ \+/ /g "remove multiple non-breaking spaces
	normal! `y
endfunction

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
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Trash (abondonned substitutes as they introduced too many bugs)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"	silent! %s/\v([;:,.!?])(\k)/\1 \2/g "Breaking space after these characters: :;,.!?
"	silent! %s/\v(\d\d) : (\d\d) : (\d\d)/\1:\2:\3/
