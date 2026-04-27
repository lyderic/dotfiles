"cursor.vim - Preserve cursor position after buffer modifications
"
"It performs the same as ma/`a, but if changes have occured
"in-between, it is taken into account to work out the best
"position of the cursor. This is mainly useful in the "sanitize.vim plugin.
"
"Usage:
"  call CursorSave()
"  ... your modifications ...
"  call CursorRestore()

if exists('g:cursor_loaded')
	finish
endif
let g:cursor_loaded = 1

let s:save_linenum = 0
let s:save_col = 0
let s:save_substr = ''
let s:save_chars_from_end = 0

function! CursorSave()
	let s:save_linenum = line('.')
	let s:save_col = col('.')
	let l:line = getline(s:save_linenum)
	let s:save_chars_from_end = len(l:line) - s:save_col + 1
	if s:save_col <= len(l:line)
		let s:save_substr = strpart(l:line, s:save_col - 1, 5)
	else
		let s:save_substr = ''
	endif
endfunction

function! CursorRestore()
	if s:save_linenum == 0
		return
	endif
	let l:max_lines = line('$')
	if s:save_linenum > l:max_lines
		call cursor(l:max_lines, len(getline(l:max_lines)) + 1)
		return
	endif
	let l:current_line = getline(s:save_linenum)
	call cursor(s:save_linenum, s:save_col)
	if s:save_substr != '' && s:save_col <= len(l:current_line)
		let l:current_substr = strpart(l:current_line, s:save_col - 1, len(s:save_substr))
		if l:current_substr == s:save_substr
			return
		endif
	endif
	let l:new_col = len(l:current_line) - s:save_chars_from_end + 1
	if l:new_col < 1
		let l:new_col = 1
	endif
	call cursor(s:save_linenum, l:new_col)
endfunction
