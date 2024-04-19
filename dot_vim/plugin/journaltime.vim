function! VimJournalTime(lang)
	let b:langnr = a:lang
	luafile $HOME/.vim/plugin/journaltime.lua
endfunction
" 1=fr 2=de 3=en 4=es
command! -nargs=1 VimJournalTime call VimJournalTime(<args>)
