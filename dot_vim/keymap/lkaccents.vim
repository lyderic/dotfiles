"Allow entering accented characters with key combinations
"On the whole:
" [ : accent aigu
" ] : accent grave
" ; : accent circonflexe (or {)
" = : tréma (or })

scriptencoding utf-8
let b:keymap_name = "àéîôù"

loadkeymap
]a à
[a à
{a â
;a â
}a ä
=a ä
]A À
[A À
{A Â
;A Â
}A Ä
=A Ä
[e é
[E É
]e è
]E È
{e ê
;e ê
}e ë
=e ë
{E Ê
;E Ê
}E Ë
=E Ë
;i î
[i î
]i î
{i î
}i ï
=i ï
{I Î
;I Î
}I Ï
=I Ï
[o œ
[O Œ
]o œ
]O Œ
{o ö
}o ö
=o ö
{O Ö
}O Ö
=O Ö
;o ô
;O Ô
[u ù
]u ù
{u û
{U û
;u û
;U û
}u ü
}U Ü
=u ü
=U Ü
[c ç
]c ç
[C Ç
]C Ç
;c ç
;C Ç
=c ç
=C Ç
~n ñ
~N Ñ
~e ᵉ
~1 ¹
~2 ²
~3 ³
~0 °
~c ©
~! ¡
~? ¿
~r ᵉʳ
