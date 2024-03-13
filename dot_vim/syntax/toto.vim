" Vim syntax file
" Language:     Gina Trapani's todo, simplified
" Maintainer: 	Lydéric Landry
" Filenames:    todo.txt
" Last Change:  2023-05-23
" Note: this file is a simplified version of the todo file format, it only
" highlights the tasks' priorities, i.e. the first three chars of each line:
" (A), (B)...

if exists("b:current_syntax")
  finish
endif

syntax match priority_A '^(A)'
syntax match priority_B '^(B)'
syntax match priority_C '^(C)'
syntax match priority_D '^(D)' 

let b:current_syntax = "toto"
hi def link priority_A Keyword
hi def link priority_B Type
hi def link priority_C Comment
hi def link priority_D String
