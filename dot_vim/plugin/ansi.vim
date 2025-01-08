"ANSI COLORING STUFF

if exists("g:ansi_stuff")
	finish
endif
let g:ansi_stuff = 1

"######################################################
" COMMANDS
"######################################################

command! -buffer Ansi call s:ansi()
command! -buffer PopupTerminal call s:popupterminal()

"######################################################
"    ABBREVIATIONS
"######################################################

iabbr <buffer> e0 \e[m
iabbr <buffer> e1 \e[1m\e[m<esc>Fma<c-o>:call getchar()<cr>
iabbr <buffer> e2 \e[2m\e[m<esc>Fma<c-o>:call getchar()<cr>
iabbr <buffer> e3 \e[3m\e[m<esc>Fma<c-o>:call getchar()<cr>
iabbr <buffer> e4 \e[4m\e[m<esc>Fma<c-o>:call getchar()<cr>
iabbr <buffer> e7 \e[7m\e[m<esc>Fma<c-o>:call getchar()<cr>
iabbr <buffer> e31 \e[31m\e[m<esc>Fma<c-o>:call getchar()<cr>
iabbr <buffer> e32 \e[32m\e[m<esc>Fma<c-o>:call getchar()<cr>
iabbr <buffer> e33 \e[33m\e[m<esc>Fma<c-o>:call getchar()<cr>
iabbr <buffer> e34 \e[34m\e[m<esc>Fma<c-o>:call getchar()<cr>
iabbr <buffer> e35 \e[35m\e[m<esc>Fma<c-o>:call getchar()<cr>
iabbr <buffer> e36 \e[36m\e[m<esc>Fma<c-o>:call getchar()<cr>
iabbr <buffer> e37 \e[37m\e[m<esc>Fma<c-o>:call getchar()<cr>

"######################################################
"    FUNCTIONS
"######################################################

if !exists("*s:ansi")
	function! s:ansi()
		let l:cmd = ['just', '-g', 'ansi', '_wait']
		let buf = term_start(l:cmd, #{hidden: 1, term_finish: 'close'})
		let winid = popup_create(buf, {
			\ 'minwidth': 32,
			\ 'minheight': 6,
			\})
	endfunction
endif

if !exists("*s:popupterminal")
	function! s:popupterminal()
		let l:cmd = ['bash', '--login']
		let buf = term_start(l:cmd, #{hidden: 1, term_finish: 'close'})
		let winid = popup_create(buf, {
			\ 'minwidth': &columns - 8,
			\ 'minheight': &lines - 8,
			\ 'maxwidth': &columns - 2,
			\ 'maxheight': &lines - 2,
			\ 'border': [],
			\ 'borderhighlight': [ 'Changed' ],
			\ 'padding': [ 0, 1, 0, 1 ],
			\ 'highlight': 'Normal', 
			\ })
	endfunction
endif
