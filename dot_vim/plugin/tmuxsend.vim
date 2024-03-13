function! TmuxSend(...)
	let l:command = join(a:000)
	let l:raw = system("tmux lsp | awk '!/active/ {print $7;exit}'")
	let l:target = trim(l:raw)
	call system('tmux send-keys -t '.l:target.' "'. l:command . '" Enter')
endfunction
command! -nargs=* TmuxSend call TmuxSend(<f-args>)

function! TmuxCommand()
	let l:command = input("command: ")
	call TmuxSend(l:command)
endfunction
command! TmuxCommand call TmuxCommand()
nnoremap <leader>u :TmuxCommand<cr>

function! TmuxMap()
	echo "the command defined here will be run on tmux pane #1 when saving"
	echo "using '<leader>=' instead of the usual '=' shortcut"
	let l:command = input("command to map: ")
	execute 'nnoremap <leader>= :w <bar> :TmuxSend ' . l:command . '<cr>'
endfunction
command! TmuxMap call TmuxMap()
