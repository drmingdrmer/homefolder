XPTemplate priority=all

let s:f = g:XPTfuncs()

XPTvar $TIME_FMT     '%H:%M:%S'

call XPTdefineSnippet("Now", {}, "`time()^")

let s:math_abbr = [
      \ [ "suba",            "ₐ"  ],
      \ [ "sube",            "ₑ"  ],
      \ [ "subo",            "ₒ"  ],
      \ [ "subx",            "ₓ"  ],
      \ [ "subinve",         "ₔ"  ],
      \ [ "sub0",            "₀"  ],
      \ [ "sub1",            "₁"  ],
      \ [ "sub2",            "₂"  ],
      \ [ "sub3",            "₃"  ],
      \ [ "sub4",            "₄"  ],
      \ [ "sub5",            "₅"  ],
      \ [ "sub6",            "₆"  ],
      \ [ "sub7",            "₇"  ],
      \ [ "sub8",            "₈"  ],
      \ [ "sub9",            "₉"  ],
      \ [ "subadd",          "₊"  ],
      \ [ "subsub",          "₋"  ],
      \ [ "subeq",           "₌"  ],
      \ [ "sublparentheses", "₍"  ],
      \ [ "subrparentheses", "₎"  ],
      \]

let s:math_abbr += [
      \ [ "sup0",            "⁰"  ],
      \ [ "sup1",            "¹"  ],
      \ [ "sup2",            "²"  ],
      \ [ "sup3",            "³"  ],
      \ [ "sup4",            "⁴"  ],
      \ [ "sup5",            "⁵"  ],
      \ [ "sup6",            "⁶"  ],
      \ [ "sup7",            "⁷"  ],
      \ [ "sup8",            "⁸"  ],
      \ [ "sup9",            "⁹"  ],
      \ [ "supi",            "ⁱ"  ],
      \ [ "supn",            "ⁿ"  ],
      \ [ "supadd",          "⁺"  ],
      \ [ "supsub",          "⁻"  ],
      \ [ "supeq",           "⁼"  ],
      \ [ "suplparentheses", "⁽"  ],
      \ [ "suprparentheses", "⁾"  ],
      \]
let s:math_abbr += [
      \ [ "all",             "∀"  ],
      \ [ "exist",           "∃"  ],
      \ [ "empty",           "∅"  ],
      \ [ "prefix",          "⊏"  ],
      \ [ "prefixeq",        "⊑"  ],
      \ [ "subset",          "⊂"  ],
      \ [ "subseteq",        "⊆"  ],
      \ [ "nosubset",        "⊄"  ],
      \ [ "noeq",            "≠"  ],
      \ [ "le",              "≤"  ],
      \ [ "ge",              "≥"  ],
      \ [ "almosteq",        "≈"  ],
      \ [ "identical",       "≡"  ],
      \ [ "struckN",         "ℕ"  ],
      \ [ "struckZ",         "ℤ"  ],
      \ [ "struckC",         "ℚ"  ],
      \ [ "struckR",         "ℝ"  ],
      \ [ "struckC",         "ℂ"  ],
      \ [ "ceiling",         "⌈`^⌉"  ],
      \ [ "floor",           "⌊`^⌋"  ],
      \ [ "sum",             "∑"  ],
      \ [ "cirx",            "⊗"  ],
      \ [ "cirplus",         "⊕"  ],
      \ [ "cirdot",          "⊙"  ],
      \ [ "partialdiff",     "∂"  ],
      \ [ "root",            "√"  ],
      \ [ "coloneq",         "≔"  ],
      \ [ "plusminus",       "±"  ],
      \ [ "symbol",          "ℵ"  ],
      \ [ "inf",             "∞"  ],
      \ [ "prime",           "′"  ],
      \ [ "degree",          "°"  ],
      \ [ "scriptl",         "ℓ"  ],
      \ [ "not",             "¬"  ],
      \ [ "and",             "∧"  ],
      \ [ "or",              "∨"  ],
      \ [ "because",         "∵"  ],
      \ [ "therefore",       "∴"  ],
      \ ]

let s:math_abbr += [
      \ [ "greekalpha",      "α"  ],
      \ [ "greekbeta",       "β"  ],
      \ [ "greekgamma",      "γ"  ],
      \ [ "greekdelta",      "δ"  ],
      \ [ "greekepsilon",    "ε"  ],
      \ [ "greekzeta",       "ζ"  ],
      \ [ "greeketa",        "η"  ],
      \ [ "greektheta",      "θ"  ],
      \ [ "greekiota",       "ι"  ],
      \ [ "greekkappa",      "κ"  ],
      \ [ "greeklambda",     "λ"  ],
      \ [ "greekmu",         "μ"  ],
      \ [ "greeknu",         "ν"  ],
      \ [ "greekxi",         "ξ"  ],
      \ [ "greekomicron",    "ο"  ],
      \ [ "greekpi",         "π"  ],
      \ [ "greekrho",        "ρ"  ],
      \ [ "greeksigma",      "σ"  ],
      \ [ "greektau",        "τ"  ],
      \ [ "greekupsilon",    "υ"  ],
      \ [ "greekphi",        "φ"  ],
      \ [ "greekchi",        "χ"  ],
      \ [ "greekpsi",        "ψ"  ],
      \ [ "greekomega",      "ω"  ],
      \ ]

let s:pref = 'um'
for [a, to] in s:math_abbr
    call XPTdefineSnippet(s:pref . a, {}, to)
    if a =~ '\v^greek'
        let upper = toupper(to)
        call XPTdefineSnippet(s:pref . a . '_u', {}, upper)
    endif
endfor


" Ϊ     Greek Capital Letter Iota with diaeresis
" Ϋ     Greek Capital Letter Upsilon with diaeresis

" ά     Greek Small Letter Alpha with acute accent
" έ     Greek Small Letter Epsilon with acute accent
" ή     Greek Small Letter Eta with acute accent
" ί     Greek Small Letter Iota with acute accent
" ΰ     Greek Small Letter Upsilon with diaeresis and acute accent

" ς     Greek Small Letter Final Sigma
" ϊ     Greek Small Letter Iota with diaeresis
" ϋ     Greek Small Letter Upsilon with diaeresis
" ό     Greek Small Letter Omicron with acute accent
" ύ     Greek Small Letter Upsilon with acute accent
" ώ     Greek Small Letter Omega with acute accent

" like u
XPT umsetopu " ⋃
XSET x=Choose(split('⋃⊌⊍⊎⨃⨄⨆', '\zs'))
`x^

" like n
XPT umsetopn " ⋂
XSET x=Choose(split('⋂⨅', '\zs'))
`x^

XPT umsetrell " ⊂
XSET x=Choose(split('⊂⊆⊈⊊⊄⫅⫋⫃⫇⫉⟃⫏⫑⫓⫕⫗⋐⟈', '\zs'))
`x^

XPT umsetrelr " ⊃
XSET x=Choose(split('⊃⊇⊉⊋⊅⫆⫌⫄⫈⫊⟄⫐⫒⫔⫖⫘⋑⟉', '\zs'))
`x^


XPT umsetrelsql " ⊏
XSET x=Choose(split('⊏⊑⋢⋤', '\zs'))
`x^

XPT umsetrelsqr " ⊐
XSET x=Choose(split('⊐⊒⋣⋥', '\zs'))
`x^

XPT umorderl " ≺
XSET x=Choose(split('≺≼≾⊀⋞⋠⋨⪯⪱⪳⪵⪷⪹⪻', '\zs'))
`x^

XPT umorderr " ≻
XSET x=Choose(split('≻≽≿⊁⋟⋡⋩⪰⪲⪴⪶⪸⪺⪼', '\zs'))
`x^

XPT umcmpl " <
XSET x=Choose(split('≮≤≰⪇≦≨', '\zs'))
`x^

XPT umcmpr " <
XSET x=Choose(split('≯≥≱⪈≧≩', '\zs'))
`x^

XPT umeltl " ∈
XSET x=Choose(split('∈∉⋶⋲⋳', '\zs'))
`x^

XPT umeltr " ∋
XSET x=Choose(split('∋∌⋽⋺⋻', '\zs'))
`x^

XPT umintegral " ∫
XSET x=Choose(split('∫∬∭∮∯∰∱∲∳⨋⨌⨍⨎⨏⨐⨑⨒⨓⨔⨕⨖⨗⨘⨙⨚⨛⨜', '\zs'))
`x^

