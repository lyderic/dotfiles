# Why this directory?

Certain filetypes plugins remap '[[' and ']]' However, I also remap them in ~/.vimrc in order to navigate the Quickfix window the way I want So in order to overwrite this, I needed to remap '[[' and ']]' in buffers where these filetypes are used, because the
filetype mappings are loaded after ~/.vimrc

I found this trick [here](Source: https://unix.stackexchange.com/questions/41743/vim-how-to-get-rid-of-filetype-specific-map)

# How does it work?

The remapping are done in `mapping_fix.vim`:

```
nnoremap <buffer>[[ :call WrapQuickFixCPrevious()<cr>
nnoremap <buffer>]] :call WrapQuickFixCNext()<cr>
```

Each filetype (that I use) that is affected is simply linked to `mapping_fix.vim`. E.g. for filetype 'foo', run:

```
$ ln -s mapping_fix.vim foo.vim
```

# How can I find out the filetype of a buffer?

In vim, run:

```
:set ft?
```

# How do I know whether I need to do this for filetype 'foo'?

Make sure you're in a buffer where a 'foo' file is loaded and run:

```
:verbose nmap [[
```

You should get **only one** line starting with `n  [[` and this line should be:

```
n  [[          * :call WrapQuickFixCPrevious()<CR>
```

If you get more than one line, then the above `ln -s` is needed.
