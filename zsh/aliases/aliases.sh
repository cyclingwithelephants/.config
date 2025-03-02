#!/usr/bin/env zsh

# formats ls as a vertical list, excluding extra information from ls -l
# CLICOLOR_FORCE=1 forces ls colour to be displayed even through piping.
# LC_COLLATE=cs_CZ.ISO8859-2 is a locale that is used to sort the alphabet in a case-insensitive way (i.e. aAbBcC rather than abcABC).
# it does sort dotfiles after Z but we're getting there.
# similar to exa -1
alias l='CLICOLOR_FORCE=1 LC_COLLATE=cs_CZ.ISO8859-2 ls -lF  | awk "{\$1=\$2=\$3=\$4=\$5=\$6=\$7=\$8=\"\"; if (NR!=1) print substr(\$0, 9)}"'
alias la='CLICOLOR_FORCE=1 LC_COLLATE=cs_CZ.ISO8859-2 ls -lFA  | awk "{\$1=\$2=\$3=\$4=\$5=\$6=\$7=\$8=\"\"; if (NR!=1) print substr(\$0, 9)}"'

# git
# other aliases are in ~/.config/git/config
alias g='git'

# kube
alias k='kubectl'
alias kg='kubectl get'
alias kx='kubectx'
alias kwatch='watch -n 1 kubectl'

alias please='sudo'

alias tf='terraform'

alias vim="nvim"

#alias ls='ls --color=auto -hv'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip -c=auto'

# -i causes mv to write a prompt to standard error before moving a file that would overwrite an existing
# file. If the response from the standard input begins with the character ‘y’ or ‘Y’, the move is attempted
alias mv='mv -i'

# prevents .wget-hsts from being created in $HOME
alias wget="wget --hsts-file=${XDG_STATE_HOME}/wget-hsts"
