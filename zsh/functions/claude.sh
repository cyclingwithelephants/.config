export CLAUDE_CODE_NO_FLICKER=1

# Rehome an orphan session jsonl into the current cwd's project bucket so
# `claude --resume <id>` works regardless of which worktree wrote the log.
# Claude Code looks up sessions by an encoded cwd ('/' and '.' -> '-').
__claude_rehome_session() {
  local id="$1"
  [[ -n "$id" ]] || return 0
  local cwd_bucket
  cwd_bucket="$(pwd | sed 's|[/.]|-|g')"

  local -a roots seen
  roots=(
    "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/projects"
    "$HOME/.config/claude/projects"
    "$HOME/.claude/projects"
  )

  local root target src
  for root in "${roots[@]}"; do
    [[ -d "$root" ]] || continue
    case " ${seen[*]} " in *" $root "*) continue ;; esac
    seen+=("$root")

    target="$root/$cwd_bucket"
    [[ -f "$target/$id.jsonl" ]] && continue

    src="$(find "$root" -maxdepth 2 -type f -name "$id.jsonl" -print 2>/dev/null | head -n1)"
    [[ -n "$src" ]] || continue

    mkdir -p "$target"
    if ln "$src" "$target/$id.jsonl" 2>/dev/null \
       || cp "$src" "$target/$id.jsonl"; then
      print -u2 "claude: rehomed session $id -> $target"
    fi
  done
}

claude() {
  local arg next resume_id="" has_resume=0
  local -a args=("$@")
  local i=1
  while (( i <= ${#args} )); do
    arg="${args[$i]}"
    case "$arg" in
      --resume|-r)
        has_resume=1
        next="${args[$((i+1))]:-}"
        [[ -n "$next" && "$next" != -* ]] && resume_id="$next"
        ;;
      --resume=*)
        has_resume=1
        resume_id="${arg#--resume=}"
        ;;
      --continue|--continue=*|-c)
        has_resume=1
        ;;
    esac
    (( i++ ))
  done

  if (( has_resume )); then
    [[ -n "$resume_id" ]] && __claude_rehome_session "$resume_id"
    command claude --permission-mode auto "$@"
    return
  fi

  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    command claude --dangerously-skip-permissions \
      --worktree "$(date +%Y-%m-%d-%H%M%S)" "$@"
  else
    command claude --dangerously-skip-permissions "$@"
  fi
}
