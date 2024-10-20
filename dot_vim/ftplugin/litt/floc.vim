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
command! -buffer FlocListPersonnages call s:showcharacters()
command! -buffer LL call s:showcharacters()

"Scenes commands
command! -buffer SC call ShowScenes()
command! -buffer -nargs=? NewScene call NewScene(<f-args>)
command! -buffer SceneFold call SceneFold()
command! -buffer EnableSceneFold call EnableSceneFold()
"autocmd! BufNewFile,BufRead *.lkl call EnableSceneFold()

"######################################################
" GLOBAL FUNCTIONS
"######################################################

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

function! s:tofilename(name) abort
	let l:filename = tolower(a:name)
	let l:filename = iconv(l:filename, 'utf-8', 'ascii//TRANSLIT')
	let l:filename = substitute(l:filename, "'", "_", "g")
	let l:filename = substitute(l:filename, '\s\+', '_', 'g')
	let l:filename = substitute(l:filename, '[^a-zA-Z0-9_]', '', 'g')
	return l:filename
endfunction

"######################################################
" CHARACTER FUNCTIONS
"######################################################

function! s:showcharacters()
	if !isdirectory(s:persdir)
		echohl ErrorMsg
		echo "Directory ".s:persdir." not found"
		echohl None
		return
	endif
	echo system("ls ".s:persdir)
endfunction

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

"######################################################
" SCENE FUNCTIONS
"######################################################

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
