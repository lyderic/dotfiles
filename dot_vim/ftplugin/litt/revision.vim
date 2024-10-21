"Les passages à revoir sont de la forme :
"	[** texte explicatif : pourquoi faut-il revoir ici ? **]

"Recherche les passages à revoir dans les buffers ouverts et
"ouvre une fenêtre Quickfix les listant
if !exists("*Revision")
	function! Revision()
		"looking in all .lkl files in dir + subdirs
		try
			execute 'vimgrep /\[\*\*/gj **/*.lkl'
		catch
			echo "rien à revoir :-)"
			return
		endtry
		copen
		cfirst
	endfunction
endif
command! -buffer Revision call Revision()
nnoremap <buffer> <leader>r :call Revision()<cr>

"Crée un passage à revoir en entrant '[[[' en mode insertion
inoremap <buffer> [[[ [**  **]<Left><Left><Left><Left>

"Supprime un passage à revoir une fois traité
"idéalement, il faudrait vérifier que nous somme dans
"une révision avant de songer à la supprimer...
nnoremap <buffer> <leader>d da]

"Highlight revisions
"highlight RevisionHL ctermbg=green guibg=green
"match RevisionHL '\[\*\*.\{-}\*\*\]'
