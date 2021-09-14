

source ${ZDOTDIR}/aliases

# This provides autocompletion
autoload -Uz compinit
compinit


# PROMPT ----------------------------------------------------------------------
autoload -U colors 
colors
# LPROMPT
export PS1="%{$fg[yellow]%}[%n@%m%{$reset_color%}%{$fg[magenta]%} %~%{$reset_color%}%{$fg[yellow]%}]: %{$reset_color%}"

# To get nice colours in my ls funciton
export LSCOLORS='fxafxxxxgxxxxxxxxxxxxx'

# for using git with SSH to autoload the agent
eval "$(ssh-agent -s)" 1> /dev/null
# this is super awkward, ssh-add spits out INFO level messages to stderr
# this could be the cause of bugs down the road, must stay aware
# TODO: is there some autonomous way to filter out a specific message from stderr?
ssh-add ~/.ssh/Adams-MBP_github 2> /dev/null

[[ /usr/local/bin/kubectl ]] && source <(kubectl completion zsh)

# Nice welcome message 
echo "=========================================="
l

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/adam/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/adam/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/adam/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/adam/google-cloud-sdk/completion.zsh.inc'; fi

# Enables the following plugins for zsh (I believe without oh-my-zsh)
# These were installed using brew
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
