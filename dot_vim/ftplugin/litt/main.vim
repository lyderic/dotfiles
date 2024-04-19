"Useful for writing in French and all

"Easy punctuation marks and accented characters key combinations
setlocal keymap=lkaccents
inoremap <buffer> << «
inoremap <buffer> >> »
inoremap <buffer> __  

"syno instead of man when hitting 'K' on word under cursor
setlocal keywordprg='syno'

"Hide line numbers
setlocal nonumber

"Show hidden no breaking spaces
"setlocal list
"setlocal listchars=tab:--»,nbsp:␣

"French spelling
setlocal spelllang=fr
setlocal spellcapcheck=
setlocal spell
nnoremap <buffer> <leader>f mm[s1z=`m
nnoremap <buffer> <leader>e mm[s1zg`m
inoremap <buffer> <c-f> <c-g>u<Esc>[s1z=`]a<c-g>u

"Enter date of day in French for diary
"command! -buffer JournalTime :r !journaltime -t -a 1 -y -s '\# '
command! -buffer JournalTime call VimJournalTime(1)

"Darkroom effect
nnoremap <buffer> <leader>o :Goyo<cr>
