

source ${ZDOTDIR}/aliases
source ${ZDOTDIR}/functions

# This is for zsh auto completion
autoload -Uz compinit
compinit


# PROMPT ----------------------------------------------------------------------
autoload -U colors 
colors
export PS1="%{$fg[yellow]%}[%n@%m%{$reset_color%}%{$fg[magenta]%} %~%{$reset_color%}%{$fg[yellow]%}]: %{$reset_color%}"

# To get nice colours in my ls funciton
export LSCOLORS='fxafxxxxgxxxxxxxxxxxxx'

# for using git with SSH to autoload the agent
eval "$(ssh-agent -s)" 1> /dev/null
# this is super awkward, ssh-add spits out INFO level messages to stderr
# this could be the cause of bugs down the road, must stay aware
# TODO: is there some autonomous way to filter out a specific message from stderr?
ssh-add ~/.ssh/personal/Adams-MBP_github 2> /dev/null

[[ /usr/local/bin/kubectl ]] && source <(kubectl completion zsh)

# # AWS default creds
# if test -f '~/.aws/credentials'; then
# 	aws_profile='default'
# 	export AWS_ACCESS_KEY_ID=$(aws configure get default.aws_access_key_id --profile $aws_profile)
# 	export AWS_SECRET_KEY=$(aws configure get default.aws_secret_access_key --profile $aws_profile)
# fi

# Updates PATH for the Google Cloud SDK.
source_if_exists '/Users/adam/google-cloud-sdk/path.zsh.inc'
# Enables shell command completion for gcloud.
source_if_exists '/Users/adam/google-cloud-sdk/completion.zsh.inc'


# Enables the following plugins for zsh (without oh-my-zsh)
# macos x86
source_if_exists /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source_if_exists /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# macos ARM
source_if_exists /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source_if_exists /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# Linux
source_if_exists /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source_if_exists /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


# Machine specific config
source_if_exists "${HOME}/.zshrc"
