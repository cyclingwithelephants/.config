# We load all oh-my-zsh related things at the top so that it doesn't overwrite anything we change

# Path to your oh-my-zsh installation.
# export ZSH="${HOME}/.config/oh-my-zsh"

#ZSH_THEME="robbyrussell"
#HYPHEN_INSENSITIVE="true" # for auto completion, _ and - will be interchangeable
# ENABLE_CORRECTION="true" # enable command auto-correction.

#plugins=(
#	colored-man-pages
#)

# source $ZSH/oh-my-zsh.sh

export CLICOLOR=1
export TERM=xterm-256color
# GLOBAL VARIABLES -----------------------------------------------------------
export PATH=$HOME/bin:/usr/bin:/bin:/usr/sbin:/sbin
export PATH='/Users/adamrummer/bin:/Library/Frameworks/Python.framework/Versions/3.7/bin:/usr/local/sbin:/Library/Frameworks/Python.framework/Versions/3.6/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin'


export PATH="/Library/TeX/texbin/:$PATH"  

# Golang vars
export GOPATH="${HOME}/go"
export GOOS="darwin"
export GOARCH="amd64"
export GOROOT="$(brew --prefix golang)/libexec"
export PATH="$PATH:${GOPATH}/bin:${GOROOT}/bin"
test -d "${GOPATH}" || mkdir "${GOPATH}"
test -d "${GOPATH}/src/github.com" || mkdir -p "${GOPATH}/src/github.com"


export GOPATH=$HOME/golang 
export GOROOT=/usr/local/opt/go/libexec
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$GOROOT/bin

export PULUMI_CONFIG_PASSPHRASE=""
# PROMPT ----------------------------------------------------------------------
# I _think_ this turns on the colours for zsh
autoload -U colors 
# LPROMPT
export PROMPT="%{$fg[yellow]%}[%n@%m%{$reset_color%}%{$fg[magenta]%} %~%{$reset_color%}%{$fg[yellow]%}] :%{$reset_color%}"

# RPROMPT
# Load git version control information
autoload -Uz vcs_info
# Format the vcs_info_msg_0_ variable
zstyle ':vcs_info:*' enable git
precmd() { vcs_info }

# Right prompt
#setopt prompt_subst
export RPROMPT='${vcs_info_msg_0_}' # prints current git branch
# To get nice colours in my ls funciton ------------------------------------------
export LSCOLORS='fxafxxxxgxxxxxxxxxxxxx'

export GO111MODULE=on
export PATH=$PATH:/usr/local/kubebuilder/bin


# for using git with SSH to autoload the agent
eval "$(ssh-agent -s)" 1> /dev/null
# this is super awkward, ssh-add spits out INFO level messages to stderr
# this could be the cause of bugs down the road, must stay aware
# TODO: is there some autonomous way to filter out a specific message from stderr?
ssh-add ~/.ssh/Adams-MBP_github 2> /dev/null
[[ /usr/local/bin/kubectl ]] && source <(kubectl completion zsh)


source ${ZDOTDIR}/aliases

# Nice welcome message - this is done after sourcing custom aliases so that we can use them.-----------------------------------------------------------
echo "=========================================="
l

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/adam/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/adam/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/adam/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/adam/google-cloud-sdk/completion.zsh.inc'; fi

# this enables the following plugins for zsh (I believe without oh-my-zsh)
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

