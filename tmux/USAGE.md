# tmux with iTerm2 keybindings

Two modes: **native** (iTerm2 renders everything) and **bridge** (tmux renders, but Cmd keys still work).

## Setup

Add to `~/.zshrc`:

```zsh
alias ta='tmux -CC new-session -A -s main'   # native iTerm2 mode
alias tt='tmux new-session -A -s main'        # bridge mode
```

For bridge mode, set the "tmux Keys" profile as default in iTerm2:
**iTerm2 → Settings → Profiles → tmux Keys → Other Actions → Set as Default**

## Starting and stopping

```zsh
# Start or reattach to a session called "main"
ta                # native mode — tmux windows become real iTerm2 tabs
tt                # bridge mode — tmux draws its own UI

# Start a named session
tmux new-session -s work
tmux -CC new-session -s work          # native mode

# List sessions
tmux ls

# Detach (leave session running in background)
# Press: Ctrl+b  then  d

# Reattach to a specific session
tmux attach -t work
tmux -CC attach -t work               # native mode

# Kill a session
tmux kill-session -t work
```

## Keybindings

### Pane splits

| Key               | Action                        | Example                              |
|-------------------|-------------------------------|--------------------------------------|
| `Cmd+D`           | Split side-by-side (vertical) | Split editor and terminal next to each other |
| `Cmd+Shift+D`     | Split top/bottom (horizontal) | Put logs underneath your editor      |
| `Ctrl+b` then `|` | Same as Cmd+D                 | Works without the iTerm2 profile     |
| `Ctrl+b` then `-` | Same as Cmd+Shift+D           | Works without the iTerm2 profile     |

After splitting, you end up in the new pane. Your working directory carries over.

### Pane navigation

| Key         | Action        |
|-------------|---------------|
| `Cmd+[`     | Previous pane |
| `Cmd+]`     | Next pane     |
| Click pane  | Select pane (mouse is enabled) |

Example workflow — three panes:

```
Cmd+D           → split into two side-by-side panes
Cmd+Shift+D     → split the right pane top/bottom
Cmd+[           → cycle back to the left pane
```

Result:

```
┌──────────┬──────────┐
│          │  pane 2  │
│  pane 1  ├──────────┤
│          │  pane 3  │
└──────────┴──────────┘
```

### Pane resizing

| Key                | Action          |
|--------------------|-----------------|
| `Cmd+Option+Up`    | Grow pane up    |
| `Cmd+Option+Down`  | Grow pane down  |
| `Cmd+Option+Left`  | Grow pane left  |
| `Cmd+Option+Right` | Grow pane right |

Each press resizes by 5 cells. You can also click and drag pane borders (mouse is enabled).

### Pane zoom

| Key                | Action                              |
|--------------------|-------------------------------------|
| `Cmd+Shift+Enter`  | Toggle zoom (fullscreen current pane) |

Zooming temporarily makes one pane fill the whole window. Press again to restore the layout. The status bar shows a `Z` flag when zoomed.

### Windows (tabs)

| Key           | Action              |
|---------------|---------------------|
| `Cmd+T`       | New window          |
| `Cmd+W`       | Close current pane (closes window when last pane) |
| `Cmd+1` – `Cmd+9` | Jump to window N |
| `Cmd+Left`    | Previous window     |
| `Cmd+Right`   | Next window         |

Example — running different tasks in tabs:

```
Cmd+T           → new window, run: npm start
Cmd+T           → new window, run: npm test -- --watch
Cmd+1           → jump back to window 1 (your editor)
Cmd+3           → check on tests in window 3
```

The status bar at the bottom shows your windows:

```
 [main]  1:zsh  2:npm  3:jest
```

The active window is highlighted in cyan.

### Misc

| Key     | Action                   |
|---------|--------------------------|
| `Cmd+K` | Clear scrollback history |
| `Ctrl+b` then `r` | Reload tmux config |

## Copy mode (scrollback)

tmux keeps a scrollback buffer per pane (50,000 lines). To browse it:

```
Ctrl+b  then  [        → enter copy mode
```

In copy mode (vi keybindings):

| Key     | Action                    |
|---------|---------------------------|
| `k`/`j` | Scroll up/down by line    |
| `Ctrl+u`/`Ctrl+d` | Scroll up/down half page |
| `/`     | Search forward             |
| `?`     | Search backward            |
| `v`     | Start selection            |
| `y`     | Copy selection and exit    |
| `q`     | Exit copy mode             |

You can also scroll with your mouse wheel or trackpad — it automatically enters copy mode.

## Sessions

Sessions group related windows. Use different sessions for different projects.

```zsh
# Create named sessions
tmux new-session -s frontend
tmux new-session -s backend

# Switch between sessions
# Press: Ctrl+b  then  s       → interactive session picker

# Or from the command line
tmux switch-client -t backend
```

## Common workflows

### Web development

```zsh
tt                              # start tmux
# Window 1: editor
vim .
# Cmd+T → Window 2: dev server
npm run dev
# Cmd+T → Window 3: split for test watcher + git
Cmd+D                           # split side-by-side
# Left pane: npm test -- --watch
# Right pane: git status, commits, etc.
```

### SSH with persistence

```zsh
ssh myserver
tmux new-session -s deploy      # start session on remote
./run-long-task.sh
# Ctrl+b  then  d              → detach
exit                            # disconnect SSH — task keeps running

# Later:
ssh myserver
tmux attach -t deploy           # pick up where you left off
```

### Pair programming

```zsh
# Person 1:
tmux new-session -s pair

# Person 2 (same machine):
tmux attach -t pair             # both see the same session in real time
```

## Native mode vs bridge mode

| | Native (`tmux -CC`) | Bridge (regular `tmux`) |
|---|---|---|
| Rendering | iTerm2 draws tabs and splits | tmux draws everything in the terminal grid |
| Cmd keys | Work automatically (iTerm2 handles them) | Work via escape sequence bridge (needs "tmux Keys" profile) |
| Mouse | Native macOS feel | Works but slightly different (tmux intercepts) |
| Over SSH | Not available | Works everywhere |
| Scrollback | iTerm2's native scrollback | tmux copy mode (`Ctrl+b [`) |
| Copy/paste | `Cmd+C`/`Cmd+V` as normal | Select with mouse, copies to clipboard automatically |

Use native mode locally for the best experience. Use bridge mode over SSH or when you want tmux's own UI.

## Troubleshooting

**Cmd keys not working in bridge mode:**
Check that the "tmux Keys" profile is active in iTerm2. Look at the title bar or check Settings → Profiles.

**Colors look wrong:**
Make sure your `$TERM` is `xterm-256color` in iTerm2 settings (Settings → Profiles → Terminal → Report Terminal Type).

**Reload after editing config:**
Press `Ctrl+b` then `r`, or run:
```zsh
tmux source-file ~/.config/tmux/tmux.conf
```

**Kill stuck tmux server:**
```zsh
tmux kill-server
```
