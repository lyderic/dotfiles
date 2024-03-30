autocmd BufNewFile,BufRead *.lkl setlocal filetype=litt
autocmd BufWrite *.lkl call Sanitize('1','$')
