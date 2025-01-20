# TERMINAL
export ZDOTDIR="${HOME}/.config/zsh"
export HISTFILE=${ZDOTDIR}/.zsh_history
export HISTSIZE=2000
export SAVEHIST=1000
export CLICOLOR=1
export LSCOLORS='fxafxxxxgxxxxxxxxxxxxx'
export PATH="/opt/homebrew/bin:${HOME}/bin:/usr/local/bin:/usr/local/sbin/usr/bin:/usr/sbin:/bin:/sbin"

# Not strictly used in MacOS but some apps still do observe this
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_STATE_HOME="${HOME}/.local/state"

# Go
export GOPATH="${HOME}/code/golang"
export GOROOT="${HOME}/go"
export GOOS="darwin"
export GO111MODULE=on

# Homebrew
export HOMEBREW_BREWFILE="${XDG_CONFIG_HOME}/brewfile/Brewfile"
export HOMEBREW_BAT=1 # uses bat instead of cat
export HOMEBREW_BOOTSNAP=1
export HOMEBREW_CLEANUP_PERIODIC_FULL_DAYS=15

# Java
# This allows java based apps to show (e.g. goland)
export _JAVA_AWT_WM_NONREPARENTING=1
