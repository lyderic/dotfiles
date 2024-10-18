"######################################################
" COMMANDS
"######################################################

"Characters commands
command! -buffer LL call ShowCharacters()

"Scenes commands
command! -buffer SC call ShowScenes()
command! -buffer -nargs=? NewScene call NewScene(<f-args>)
command! -buffer SceneFold call SceneFold()
command! -buffer EnableSceneFold call EnableSceneFold()
autocmd! BufNewFile,BufRead *.lkl call EnableSceneFold()


"######################################################
" FUNCTIONS
"######################################################

if !exists("*ShowCharacters")
	function! ShowCharacters()
		echo system("ls floc/personnages")
	endfunction
endif

if !exists("*ShowScenes")
	function! ShowScenes()
		"looking in all .lkl files in dir + subdirs
		try
			execute 'vimgrep #\[//# **/*.lkl'
		catch
			echo "Aucune scène trouvée"
			return
		endtry
		copen
		cfirst
	endfunction
endif

"Enable folding in main text
if !exists("*EnableSceneFold")
	function! EnableSceneFold()
		setlocal foldcolumn=2
		setlocal foldmethod=expr
		setlocal foldexpr=SceneFold()
	endfunction
endif

if !exists("*SceneFold")
	function! SceneFold()
		let b:currentline = getline(v:lnum)
		let b:nextline = getline(v:lnum+1)
		if b:currentline =~# '^#'
			return 0
		endif
		if b:nextline =~# '^#'
			return 0
		endif
		if b:nextline =~# '^[//'
			return '<1'
		endif
		if b:currentline =~# '^[//'
			return '>1'
		endif
		return '='
	endfunction
endif

if !exists("*NewScene")
	function! NewScene(...)
		if a:0 > 0
			let l:numero = join(a:000)
		else
			let l:numero = input("Numero ? ")
		endif
		let l:formatted = printf("%03d", l:numero)
		execute "normal! i[//" . l:formatted . "]: # ("
		startinsert!
	endfunction
endif
