
if [ -f ~/.profile ]; then
   source ~/.profile
fi

# 只在交互式 shell 中加载 .bashrc
if [[ $- == *i* ]]; then
    if [ -f ~/.bashrc ]; then
        source ~/.bashrc
    fi
fi

# # >>> conda initialize >>>
# # !! Contents within this block are managed by 'conda init' !!
# __conda_setup="$('/Users/drdrxp/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     if [ -f "/Users/drdrxp/miniconda3/etc/profile.d/conda.sh" ]; then
#         . "/Users/drdrxp/miniconda3/etc/profile.d/conda.sh"
#     else
#         export PATH="/Users/drdrxp/miniconda3/bin:$PATH"
#     fi
# fi
# unset __conda_setup
# # <<< conda initialize <<<


# python virtual env
. $HOME/xp/py3virtual/p3-12-4/bin/activate
