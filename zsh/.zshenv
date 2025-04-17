# not strictly used in MacOS but many apps observe this
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_STATE_HOME="${HOME}/.local/state"

# zsh
export ZDOTDIR="${HOME}/.config/zsh"
export ZSH_LOG_FILE="${XDG_DATA_HOME}/.zsh_logs"
export HISTFILE="${XDG_STATE_HOME}/.zsh_history"
export HISTSIZE=100000
export SAVEHIST=100000

# terminal
export CLICOLOR=1
export LSCOLORS='fxafxxxxgxxxxxxxxxxxxx'
export PATH="/opt/homebrew/bin:${HOME}/bin:/Library/TeX/texbin:/Applications/GoLand.app/Contents/MacOS:${PATH}"

# go
export GOPATH="${XDG_CACHE_HOME}/go"
export GOBIN="${XDG_DATA_HOME}/go"
export GOOS="darwin"
export GO111MODULE=on

# homebrew
export HOMEBREW_BREWFILE="${XDG_CONFIG_HOME}/brewfile/Brewfile"
export HOMEBREW_BAT=1 # uses bat instead of cat
export HOMEBREW_BOOTSNAP=1

# java
# this allows java based apps to show (e.g. goland)
export _JAVA_AWT_WM_NONREPARENTING=1

# prevents less from creating the .lesshst file in $HOME
export LESSHISTFILE="${XDG_STATE_HOME}/less/history"

# seems to be broken
# # enabled vim to follow the XDG spec, storing config in $XDG_CONFIG_HOME/vim/vimrc
# export VIMINIT='let $MYVIMRC="$XDG_CONFIG_HOME/vim/vimrc" | source $MYVIMRC'
