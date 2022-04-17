local wezterm = require 'wezterm';

function hsb(h, s, b)
    -- convert 255, 255, 255 into 360', 100%, 100%
    return string.format("hsv(%.0f, %.0f%%, %.0f%%)", h*360/255, s*100/255, b*100/255)
end

return {
    colors = {
        foreground = hsb(42, 0, 198),
        background = hsb(0, 0, 0),
        cursor_bg  = hsb(5, 247, 255),
        cursor_fg  = hsb(0, 0, 0),

        -- Specifies the border color of the cursor when the cursor style is set to Block,
        -- or the color of the vertical or horizontal bar when the cursor style is set to
        -- Bar or Underline.
        cursor_border = "#52ad70",

        -- the foreground color of selected text
        selection_fg = hsb(42, 0, 198),
        -- the background color of selected text
        selection_bg = hsb(151, 82, 102),

        -- The color of the scrollbar "thumb"; the portion that represents the current viewport
        scrollbar_thumb = "#222222",

        -- The color of the split lines between panes
        split = "#444444",

        ansi = {
            hsb(0,   0,   0   ), -- "black",
            hsb(252, 109, 136 ), -- "maroon",
            hsb(65,  204, 128 ), -- "green",
            hsb(31,  245, 200 ), -- "olive",
            hsb(155, 131, 197 ), -- "navy",
            hsb(207, 72,  141 ), -- "purple",
            hsb(127, 69,  61  ), -- "teal",
            hsb(0,   0,   193 ), -- "silver"
        },
        brights = {
            hsb(0,   0,   85  ), -- "grey",
            hsb(252, 109, 254 ), -- "red",
            hsb(65,  143, 213 ), -- "lime",
            hsb(31,  157, 252 ), -- "yellow",
            hsb(155, 131, 254 ), -- "blue",
            hsb(207, 54,  188 ), -- "fuchsia",
            hsb(127, 100, 138 ), -- "aqua",
            hsb(0,   0,   255 ), -- "white"
        },

        -- Arbitrary colors of the palette in the range from 16 to 255
        indexed = {[136] = "#af8700"},

        -- Since: 20220319-142410-0fcdea07
        -- When the IME, a dead key or a leader key are being processed and are effectively
        -- holding input pending the result of input composition, change the cursor
        -- to this color to give a visual cue about the compose state.
        compose_cursor = "orange",
    },

    -- debug_key_events = true,

    font = wezterm.font(
            "Monaco",
            {
                -- weight="Bold",
                -- italic=true
            }
    ),
    font_size = 12.0, 
    line_height = 1.0, 

    --

    hide_tab_bar_if_only_one_tab = true,
    enable_scroll_bar = false,
    window_decorations = "RESIZE",
    window_padding = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
    },

    window_close_confirmation = "AlwaysPrompt",

    keys = {
        { key="n", mods="CMD|ALT", action="SpawnWindow"},

        -- window control

        { key = "p",          mods="CMD|ALT", action=wezterm.action{SplitHorizontal={domain="CurrentPaneDomain"}}},
        { key = "w",          mods="CMD|ALT", action=wezterm.action{CloseCurrentPane={confirm=true}}},
        { key = "z",          mods="CMD|ALT", action="TogglePaneZoomState" },
        { key = "LeftArrow",  mods="CMD|ALT", action=wezterm.action{ActivatePaneDirection="Left"}},
        { key = "RightArrow", mods="CMD|ALT", action=wezterm.action{ActivatePaneDirection="Right"}},

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
        -- {key="c", mods="CMD", action={SendKey={key="c", mods="ALT"}}},
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
        -- {key="v", mods="CMD", action={SendKey={key="v", mods="ALT"}}},
        {key="w", mods="CMD", action={SendKey={key="w", mods="ALT"}}},
        {key="x", mods="CMD", action={SendKey={key="x", mods="ALT"}}},
        {key="y", mods="CMD", action={SendKey={key="y", mods="ALT"}}},
        {key="z", mods="CMD", action={SendKey={key="z", mods="ALT"}}},

        {key=".", mods="CMD", action={SendKey={key=".", mods="ALT"}}},
        {key=",", mods="CMD", action={SendKey={key=",", mods="ALT"}}},
    },
}
