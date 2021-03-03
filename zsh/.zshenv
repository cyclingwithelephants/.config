ZDOTDIR="${HOME}/.config/dotfiles/zsh"

# TERMINAL
export CLICOLOR=1
export XDG_CONFIG_HOME="${HOME}/.config/dotfiles"
export LSCOLORS='fxafxxxxgxxxxxxxxxxxxx'

# PATH
export PATH="${HOME}/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# GOLANG
export GOPATH="${HOME}/code/golang"
export GOOS="darwin"
export GOARCH="amd64"
export GOROOT=/usr/local/opt/go/libexec
export GO111MODULE=on
export PATH="${PATH}:${GOPATH}/bin:${GOROOT}/bin"
# test -d "${GOPATH}" || mkdir "${GOPATH}"
# test -d "${GOPATH}/src/github.com" || mkdir -p "${GOPATH}/src/github.com"

# PULUMI
export PULUMI_CONFIG_PASSPHRASE=""
