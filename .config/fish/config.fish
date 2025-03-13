# Path to Oh My Fish install.
set -q XDG_DATA_HOME
  and set -gx OMF_PATH "$XDG_DATA_HOME/omf"
  or set -gx OMF_PATH "$HOME/.local/share/omf"

# Customize Oh My Fish configuration path.
#set -gx OMF_CONFIG "/Users/drdrxp/.config/omf"

# Load oh-my-fish configuration.
source $OMF_PATH/init.fish

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /Users/drdrxp/miniconda3/bin/conda
    eval /Users/drdrxp/miniconda3/bin/conda "shell.fish" "hook" $argv | source
else
    if test -f "/Users/drdrxp/miniconda3/etc/fish/conf.d/conda.fish"
        . "/Users/drdrxp/miniconda3/etc/fish/conf.d/conda.fish"
    else
        set -x PATH "/Users/drdrxp/miniconda3/bin" $PATH
    end
end
# <<< conda initialize <<<

