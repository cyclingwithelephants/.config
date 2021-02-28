# We load all oh-my-zsh related things at the top so that it doesn't overwrite anything we change

# Path to your oh-my-zsh installation.
# export ZSH="${HOME}/.config/oh-my-zsh"

#ZSH_THEME="robbyrussell"
#HYPHEN_INSENSITIVE="true" # for auto completion, _ and - will be interchangeable
# ENABLE_CORRECTION="true" # enable command auto-correction.

#plugins=(
#	colored-man-pages
#)
source ${ZDOTDIR}/aliases

# This 
autoload -Uz compinit
compinit


# PROMPT ----------------------------------------------------------------------
autoload -U colors 
colors
# LPROMPT
export PS1="%{$fg[yellow]%}[%n@%m%{$reset_color%}%{$fg[magenta]%} %~%{$reset_color%}%{$fg[yellow]%}]: %{$reset_color%}"

# RPROMPT
# Load git version control information
autoload -Uz vcs_info
# Format the vcs_info_msg_0_ variable
zstyle ':vcs_info:git*' formats "%b" 
precmd() { vcs_info }

# Right prompt
#setopt prompt_subst
# export RPROMPT='${vcs_info_msg_0_}' # prints current git branch

# To get nice colours in my ls funciton
export LSCOLORS='fxafxxxxgxxxxxxxxxxxxx'

# for using git with SSH to autoload the agent
eval "$(ssh-agent -s)" 1> /dev/null
# this is super awkward, ssh-add spits out INFO level messages to stderr
# this could be the cause of bugs down the road, must stay aware
# TODO: is there some autonomous way to filter out a specific message from stderr?
ssh-add ~/.ssh/Adams-MBP_github 2> /dev/null

[[ /usr/local/bin/kubectl ]] && source <(kubectl completion zsh)




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

