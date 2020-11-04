# GLOBAL VARIABLES -----------------------------------------------------------
export PATH=$HOME/bin:/usr/bin:/bin:/usr/sbin:/sbin
export PATH='/Users/adamrummer/bin:/Library/Frameworks/Python.framework/Versions/3.7/bin:/usr/local/sbin:/Library/Frameworks/Python.framework/Versions/3.6/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin'
# Golang vars
export GOPATH="${HOME}/go"
export GOOS="darwin"
export GOARCH="amd64"
export GOROOT="$(brew --prefix golang)/libexec"
export PATH="$PATH:${GOPATH}/bin:${GOROOT}/bin"
test -d "${GOPATH}" || mkdir "${GOPATH}"
test -d "${GOPATH}/src/github.com" || mkdir -p "${GOPATH}/src/github.com"



# Path to your oh-my-zsh installation.
export ZSH="${HOME}/.config/oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"

HYPHEN_INSENSITIVE="true" # for auto completion, _ and - will be interchangeable
ENABLE_CORRECTION="true" # enable command auto-correction.

plugins=(
	zsh-syntax-highlighting
	zsh-autosuggestions
	colored-man-pages
)

source $ZSH/oh-my-zsh.sh


# PROMPT ----------------------------------------------------------------------
# Pretty colours
yellow=$FG[226]
purple=$FG[005]
reset=%{$reset_color%}

# Left prompt
export PS1="${yellow}[%n@%m${reset}${purple} %~${reset}${yellow}] :${reset}"

# Load git version control information
autoload -Uz vcs_info
precmd() { vcs_info }
# Format the vcs_info_msg_0_ variable
zstyle ':vcs_info:git:*' formats 'on branch %b'
# Right prompt
export RPROMPT=\$vcs_info_msg_0_ # prints current git branch


# To get nice colours in my ls funciton ------------------------------------------
export LSCOLORS='fxafxxxxgxxxxxxxxxxxxx'

# Setting up aliases for personal commands ---------------------------------------
alias ls="ls -GlhF"
alias ML='. ~/bin/ML_venv_switch'
alias please='sudo'
# alias rdp='~/Desktop/Tools/rdp'
# alias pish='push'
# alias repos='cd ~/Documents/Git'
alias g='git'
alias k='kubectl'
# alias w='watch'
# alias reload="exec ${SHELL} -l"
# alias idGroups="id -a | sed 's|,|\n|g'"
# alias ll="ls -lA $LS_COLORS"
# alias watch='watch -n 1'
alias kwatch='watch -n 1 kubectl'
alias kx='kubectx'
alias kn='kubens'


alias box='ssh adam@192.168.50.107 -i ~/.ssh/adam@box'
# Variables -----------------------------------------------------------------------
my_pub_ip="ifconfig en0 | grep 'inet ' | awk '{print $2}'"
# Nice welcome message -----------------------------------------------------------
ls

# Autoloading functions --------------------------------------------------------
for file in ~/.oh-my-zsh/functions/*; do
	autoload -Uz $(basename "${file}")
done


export GO111MODULE=on
export PATH=$PATH:/usr/local/kubebuilder/bin
alias kc='kubectl'

# for using git with SSH to autoload the agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/github

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/adamrummer/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/adamrummer/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/adamrummer/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/adamrummer/Downloads/google-cloud-sdk/completion.zsh.inc'; fi
[[ /usr/local/bin/kubectl ]] && source <(kubectl completion zsh)
