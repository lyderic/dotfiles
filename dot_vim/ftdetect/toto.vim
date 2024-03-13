autocmd BufNewFile,BufRead todo.txt setlocal filetype=toto
autocmd BufWrite todo.txt call Todoformat()
