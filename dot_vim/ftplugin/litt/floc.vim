"######################################################
" GLOBAL VARIABLES
"######################################################

let s:flocdir = "floc"
let s:persdir = s:flocdir."/personnages"

"######################################################
" COMMANDS
"######################################################

command! -buffer FlocInit call s:flocinit()

"Characters commands
command! -buffer -nargs=? NewPersonnage call s:newpers(<f-args>)
command! -buffer -nargs=? FlocNewPersonnage call s:newpers(<f-args>)
command! -buffer FlocListPersonnages call s:listcharacters()
command! -buffer LL call s:listcharacters()

"Scenes commands
command! -buffer FlocListScenes call s:listscenes()
command! -buffer SC call s:listscenes()
command! -buffer NewScene call s:newscene()
command! -buffer FlocNewScene call s:newscene()
command! -buffer EnableSceneFold call s:enablescenefold()
"autocmd! BufNewFile,BufRead *.lkl call s:enablescenefold()

"######################################################
" GENERAL FUNCTIONS
"######################################################

if !exists("*s:flocinit")
	function! s:flocinit()
		if isdirectory(s:flocdir) | return | endif
		echo system("mkdir -pv floc/personnages")
		let l:src = "~/.vim/templates/floc:synopsis.lkl"
		let l:dst = s:flocdir."/synopsis.lkl"
		echo system("cp -v ".l:src." ".l:dst)
		echohl WarningMsg
		echo "floc initialized"
		echohl None
	endfunction
endif

if !exists("*s:tofilename")
	function! s:tofilename(name) abort
		let l:filename = tolower(a:name)
		let l:filename = iconv(l:filename, 'utf-8', 'ascii//TRANSLIT')
		let l:filename = substitute(l:filename, "'", "_", "g")
		let l:filename = substitute(l:filename, '\s\+', '_', 'g')
		let l:filename = substitute(l:filename, '[^a-zA-Z0-9_]', '', 'g')
		return l:filename
	endfunction
endif

"######################################################
" CHARACTER FUNCTIONS
"######################################################

if !exists("*s:listcharacters")
	function! s:listcharacters()
		if !isdirectory(s:persdir)
			echohl ErrorMsg
			echo "Directory ".s:persdir." not found"
			echohl None
			return
		endif
		echo system("ls ".s:persdir)
	endfunction
endif

if !exists("*s:newpers")
	function! s:newpers(...)
		call s:flocinit()
		if a:0 > 0
			let l:name = join(a:000)
		else
			let l:name = input("name? ")
		endif
		let l:filename = s:tofilename(l:name)
		let l:path = s:persdir."/".l:filename.".lkl"
		if filereadable(l:path)
			echohl WarningMsg
			echo "file ".l:path." already exists"
			echohl None
			return
		endif
		execute "edit " . l:path
		execute "read ~/.vim/templates/floc:personnage.lkl"
		execute "s/Nom/".l:name."/"
		execute "1d"
	endfunction
endif

"######################################################
" SCENE FUNCTIONS
"######################################################

if !exists("*s:listscenes")
	function! s:listscenes()
		"looking in all .lkl files in dir + subdirs
		try
			execute 'vimgrep #^\[//#j **/*.lkl'
		catch
			echo "Aucune scène trouvée"
			return
		endtry
		copen
		cfirst
	endfunction
endif

if !exists("*s:enablescenefold")
	function! s:enablescenefold()
	setlocal foldcolumn=2
		setlocal foldmethod=expr
		setlocal foldexpr=s:scenefold()
	endfunction
endif

if !exists("*s:scenefold")
	function! s:scenefold()
		let l:currentline = getline(v:lnum)
		let l:nextline = getline(v:lnum+1)
		if l:currentline =~# '^#'
			return 0
		endif
		if l:nextline =~# '^#'
			return 0
		endif
		if l:nextline =~# '^[//'
			return '<1'
		endif
		if l:currentline =~# '^[//'
			return '>1'
		endif
		return '='
	endfunction
endif

if !exists("*s:newscene")
	function! s:newscene()
		let l:id = system("pwgen -A -1 -v 4 | tr -d '\n'")
		if getline(line('.')) =~ '\S' | execute "normal! o" | endif
		execute "normal! o[//".l:id."]: # ("
		startinsert!
	endfunction
endif
