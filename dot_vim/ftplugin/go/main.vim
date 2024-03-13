"GOLANG STUFF

"as goimport is run at each save
autocmd! BufNewFile,BufRead *.go set autoread

"run goimports on demand with a shortcut
nnoremap <buffer> <leader>i :!goimports -w %<cr>

"run goimports every time a go buffer is saved
autocmd! BufWritePost *.go silent! execute "!goimports -w %" | redraw!

"Some useful expands for go programming
iabbr <buffer> iferr if err != nil { panic(err) }
iabbr <buffer> errnn ; err != nil {  return}
iabbr <buffer> cmdo cmd.Stdout, cmd.Stderr = os.Stdout, os.Stderr
iabbr <buffer> cmdi cmd.Stdin, cmd.Stdout, cmd.Stderr = os.Stdin, os.Stdout, os.Stderr
cabbr <buffer> cmdc s/cmd/comm/g
iabbr <buffer> gtools . "github.com/lyderic/tools"

"Compiler should be go
compiler go

"----------------------------------------------
"    FUNCTIONS
"----------------------------------------------

"Import tools at the right place
function! ImportTools()
	normal! magg
	/^import
	normal! o . "github.com/lyderic/tools"
	normal! `a
	write
endfunction
command! -buffer ImportTools call ImportTools()

"Remove tools import
function! RemoveTools()
	normal! ma
	g#github.com/lyderic/tools#d
	normal! `a
	write
endfunction
command! -buffer RemoveTools call RemoveTools()

"main template
function! Gomain()
	normal! ipackage main
	normal! ofunc main() {
	normal! o}
	normal! ki	
endfunction
command! -buffer Gomain call Gomain()
