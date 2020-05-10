let s:norm = ['0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','+','-','=','(',')']
let s:subs = ['₀','₁','₂','₃','₄','₅','₆','₇','₈','₉','ₐ','ᵦ',' ',' ','ₑ',' ','ᵧ',' ','ᵢ','ⱼ',' ',' ',' ',' ','ₒ',' ',' ','ᵣ',' ',' ','ᵤ','ᵥ',' ','ₓ',' ',' ','₊','₋','₌','₍','₎']
let s:sups = ['⁰','¹','²','³','⁴','⁵','⁶','⁷','⁸','⁹','ᵃ','ᵇ','ᶜ','ᵈ','ᵉ','ᶠ','ᵍ','ʰ','ⁱ','ʲ','ᵏ','ˡ','ᵐ','ⁿ','ᵒ','ᵖ',' ','ʳ','ˢ','ᵗ','ᵘ','ᵛ','ʷ','ˣ','ʸ','ᶻ','⁺','⁻','⁼','⁽','⁾']

fun! edit#case#Next(c) "{{{
    let c = a:c
    if c == ' '
        return ' '
    endif

    let i = index(s:norm, c)
    if i >= 0
        return s:subs[i]
    endif

    let i = index(s:subs, c)
    if i >= 0
        return s:sups[i]
    endif

    let i = index(s:sups, c)
    if i >= 0
        return s:subs[i]
    endif

    return ' '

endfunction "}}}

fun! edit#case#Switch() "{{{
    let [x, l, c, y] = getpos(".")
    let line = getline(l)
    let c = matchstr(line, '\v.', c-1)
    let nxt = edit#case#Next(c)
    if nxt == ' '
        " fallback
        return '~'
    endif

    return "s" . nxt . "\<Esc>"
endfunction "}}}

