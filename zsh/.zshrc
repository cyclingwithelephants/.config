for func in ${ZDOTDIR}/functions/*; do
  source "$func"
done

for alias_file in ${ZDOTDIR}/aliases/*; do
  source "$alias_file"
done

# this seems to need to be set in .zshrc over .zshenv
HISTFILE=$XDG_STATE_HOME/zsh/history

# This is for zsh auto-completion
# -d sets the directory to store completions
autoload -U compinit
compinit -d "${XDG_DATA_DIR}/zsh"

setopt inc_append_history

# prompt
PS1='%F{yellow}%n@%m% %f %F{magenta}%~%f %F{yellow}>%f '

# for using git with SSH to autoload the agent
eval "$(ssh-agent -s)" 1> /dev/null
# this is super awkward, ssh-add spits out INFO level messages to stderr
# this could be the cause of bugs down the road, must stay aware
# TODO: is there some autonomous way to filter out a specific message from stderr?
ssh-add ~/.ssh/personal/Adams-MBP_github 2> /dev/null

[[ /usr/local/bin/kubectl ]] && source <(kubectl completion zsh)

# Updates PATH for the Google Cloud SDK.
source_if_exists '/Users/adam/google-cloud-sdk/path.zsh.inc'
# Enables shell command completion for gcloud.
source_if_exists '/Users/adam/google-cloud-sdk/completion.zsh.inc'

# Enables the following plugins for zsh (without oh-my-zsh)
source_if_exists /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source_if_exists /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Machine specific config
source_if_exists "${HOME}/.zshrc"
