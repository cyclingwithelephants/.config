ZDOTDIR="${HOME}/.config/zsh"

# TERMINAL
export CLICOLOR=1
export TERM=alacritty
# Not strictly used in MacOS but some apps still do observe this
export XDG_CONFIG_HOME="${HOME}/.config/"
export LSCOLORS='fxafxxxxgxxxxxxxxxxxxx'

# PATH
export PATH="${HOME}/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# GOLANG
export GOPATH="${HOME}/code/golang"
export GOOS="darwin"
export GOARCH="amd64"
export GOROOT=/usr/local/opt/go/libexec
export GO111MODULE=on
export PATH="$PATH:${GOPATH}/bin:${GOROOT}/bin"
