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

alias tf='tofu'
alias ts='tailscale'

# Sync claude config to radish (run once, or after changing settings/plugins)
cc-sync() {
    rsync -az --delete \
        --exclude='.credentials.json' \
        --exclude='file-history/' \
        --exclude='paste-cache/' \
        --exclude='session-env/' \
        --exclude='sessions/' \
        --exclude='shell-snapshots/' \
        --exclude='tasks/' \
        --exclude='telemetry/' \
        --exclude='history.jsonl' \
        --exclude='stats-cache.json' \
        --exclude='.DS_Store' \
        ~/.claude/ radish:~/.claude/
    [[ -f ~/.claude.json ]] && scp -q ~/.claude.json radish:~/.claude.json
    echo "Claude config synced to radish"
}

# Claude session on radish
# Usage: cc <repo>          → single session
#        cc -n 5 <repo>     → 5 sessions in tmux
# Repo defaults to cyclingwithelephants/ prefix
cc() {
    local count=1 repo=""
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -n) count="$2"; shift 2 ;;
            *)  repo="$1"; shift ;;
        esac
    done
    if (( count < 1 || count > 10 )); then
        echo "count must be 1-10"; return 1
    fi
    [[ -n "$repo" && "$repo" != */* ]] && repo="cyclingwithelephants/$repo"
    local dir="code/github.com/$repo"

    # Ensure repo exists (clone if missing, skip fetch — worktree handles it)
    ssh radish "cd ~/code/github.com/$repo 2>/dev/null && git rev-parse --git-dir >/dev/null 2>&1 || { mkdir -p ~/code/github.com/$repo && git clone https://github.com/$repo.git ~/code/github.com/$repo; }"

    local repo_short="${repo##*/}"

    # Ensure tmux session exists; create with btop in first window if new
    # remain-on-exit keeps the pane alive if btop isn't installed yet
    ssh radish "tmux has-session -t cc 2>/dev/null || { tmux new-session -d -s cc -n btop; tmux set-option -t cc:btop remain-on-exit on; tmux send-keys -t cc:btop btop Enter; }"

    # Count existing windows for this repo to avoid name collisions
    local existing=$(ssh radish "tmux list-windows -t cc -F '#W' 2>/dev/null | grep -c '^${repo_short}-'")

    for i in $(seq 1 $count); do
        local n=$(( existing + i ))
        local wt="cc-$(date +%H%M%S)-$i"
        local win_name="${repo_short}-${n}"
        ssh radish "tmux new-window -t cc -n '$win_name' \"cd ~/$dir && /opt/homebrew/bin/claude --dangerously-skip-permissions --worktree $wt\""
    done
    ssh -t radish "tmux attach -t cc"
}

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
