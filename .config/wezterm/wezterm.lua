local wezterm = require 'wezterm';

return {
    color_scheme = "Afterglow",

    font = wezterm.font(
            "Monaco",
            { weight="Bold",
              -- italic=true
            }
    ),

    keys = {

        {key="0", mods="CMD", action={SendKey={key="0", mods="ALT"}}}, 
        {key="1", mods="CMD", action={SendKey={key="1", mods="ALT"}}}, 
        {key="2", mods="CMD", action={SendKey={key="2", mods="ALT"}}}, 
        {key="3", mods="CMD", action={SendKey={key="3", mods="ALT"}}}, 
        {key="4", mods="CMD", action={SendKey={key="4", mods="ALT"}}}, 
        {key="5", mods="CMD", action={SendKey={key="5", mods="ALT"}}}, 
        {key="6", mods="CMD", action={SendKey={key="6", mods="ALT"}}}, 
        {key="7", mods="CMD", action={SendKey={key="7", mods="ALT"}}}, 
        {key="8", mods="CMD", action={SendKey={key="8", mods="ALT"}}}, 
        {key="9", mods="CMD", action={SendKey={key="9", mods="ALT"}}}, 

        {key="a", mods="CMD", action={SendKey={key="a", mods="ALT"}}}, 
        {key="b", mods="CMD", action={SendKey={key="b", mods="ALT"}}}, 
        {key="c", mods="CMD", action={SendKey={key="c", mods="ALT"}}}, 
        {key="d", mods="CMD", action={SendKey={key="d", mods="ALT"}}}, 
        {key="e", mods="CMD", action={SendKey={key="e", mods="ALT"}}}, 
        {key="f", mods="CMD", action={SendKey={key="f", mods="ALT"}}}, 
        {key="g", mods="CMD", action={SendKey={key="g", mods="ALT"}}}, 
        {key="h", mods="CMD", action={SendKey={key="h", mods="ALT"}}}, 
        {key="i", mods="CMD", action={SendKey={key="i", mods="ALT"}}}, 
        {key="j", mods="CMD", action={SendKey={key="j", mods="ALT"}}}, 
        {key="k", mods="CMD", action={SendKey={key="k", mods="ALT"}}}, 
        {key="l", mods="CMD", action={SendKey={key="l", mods="ALT"}}}, 
        {key="m", mods="CMD", action={SendKey={key="m", mods="ALT"}}}, 
        {key="n", mods="CMD", action={SendKey={key="n", mods="ALT"}}}, 
        {key="o", mods="CMD", action={SendKey={key="o", mods="ALT"}}}, 
        {key="p", mods="CMD", action={SendKey={key="p", mods="ALT"}}}, 
        {key="q", mods="CMD", action={SendKey={key="q", mods="ALT"}}}, 
        {key="r", mods="CMD", action={SendKey={key="r", mods="ALT"}}}, 
        {key="s", mods="CMD", action={SendKey={key="s", mods="ALT"}}}, 
        {key="t", mods="CMD", action={SendKey={key="t", mods="ALT"}}}, 
        {key="u", mods="CMD", action={SendKey={key="u", mods="ALT"}}}, 
        {key="v", mods="CMD", action={SendKey={key="v", mods="ALT"}}}, 
        {key="w", mods="CMD", action={SendKey={key="w", mods="ALT"}}}, 
        {key="x", mods="CMD", action={SendKey={key="x", mods="ALT"}}}, 
        {key="y", mods="CMD", action={SendKey={key="y", mods="ALT"}}}, 
        {key="z", mods="CMD", action={SendKey={key="z", mods="ALT"}}}, 

        -- {key=".", mods="ALT", action={SendString="\x1b."}}, 
        {key=".", mods="CMD", action={SendString="dot"}}, 
        -- {key=".", mods="ALT", action={SendString="dot"}}, 
        {key=",", mods="CMD", action={SendKey={key=",", mods="ALT"}}}, 
    }, 
}
