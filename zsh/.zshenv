ZDOTDIR="${HOME}/.config/zsh"

# TERMINAL
export CLICOLOR=1
#export TERM=alacritty
# Not strictly used in MacOS but some apps still do observe this
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache/"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_STATE_HOME="${HOME}/.local/state"

export LSCOLORS='fxafxxxxgxxxxxxxxxxxxx'

# PATH
export PATH="${HOME}/bin:/usr/local/bin:/usr/local/sbin/usr/bin:/usr/sbin:/bin:/sbin"

# GOLANG
export GOPATH="${HOME}/code/golang"
export GOOS="darwin"
export GOARCH="amd64"
export GOROOT=/usr/local/opt/go/libexec
export GO111MODULE=on
export PATH="$PATH:${GOPATH}/bin:${GOROOT}/bin:$HOME/bin"

# Homebrew
export HOMEBREW_CASK_OPTS="--appdir=${HOME}/Applications"

# Java
# This allows java based apps to show (e.g. goland)
export _JAVA_AWT_WM_NONREPARENTING=1

# Save command history
export HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
export HISTSIZE=2000
export SAVEHIST=1000
