# darwin/

nix-darwin configuration for adam's personal Macs. Currently models
`shallot` (workstation). `radish` (Mac mini, hermes appliance) lives in
the cluster repo and is not managed here.

## Why this exists

`bootstrap.sh` used to bash-imperative the entire Mac setup: hostname via
`scutil`, GUI tweaks via `defaults write`, sudo via raw `visudo` and `sed`
into `/etc/pam.d/sudo`, packages via `brew bundle`. That worked, but had
two failure modes:

1. **No source of truth for what the OS is supposed to look like.** Drift
   between machines, no rollback, no audit trail.
2. **An orphan `nix-darwin` install on shallot silently overwrote
   HostName=radish for ~7 weeks** because nothing in this repo was the
   declared truth — there was nothing for `darwin-rebuild` to converge
   _to_. Tailscale registered the laptop as `radish-1`. Filed under
   "the rogue install".

The fix: make a per-host `.nix` module the declared truth. `bootstrap.sh`
shrinks to "install nix + Homebrew + hand off to nix-darwin".

## Layout

```
darwin/
  flake.nix              # inputs (nixpkgs unstable, nix-darwin, nix-homebrew)
                         # + darwinConfigurations.<host> for each Mac
  shallot.nix            # full host module: identity, defaults, sudo, brew
  lib/
    parse-brewfile.nix   # reads ../homebrew/Brewfile.<host> into a list
                         # so the homebrew module + the brew() shell wrapper
                         # share one file as source of truth
```

## How to extend

### Add a new Mac

1. Create `darwin/<host>.nix` (copy `shallot.nix`, tweak identity + defaults)
2. Add `darwinConfigurations.<host>` block to `flake.nix`
3. Create `bootstrap/config/<host>.sh` with `hostname=<host>`
4. Create `homebrew/Brewfile.<host>` (or symlink an existing one to share)
5. Run `bootstrap/bootstrap.sh <host>` on the new machine

### Change a system default

Edit `<host>.nix`. Run `sudo darwin-rebuild switch --flake ~/.config/darwin#<host>`.
Don't `defaults write` from the shell — the next switch will revert you
(or worse, the value will silently drift between machines).

### Install / uninstall a brew package

```sh
brew install <pkg>     # or `brew install --cask <pkg>`
brew uninstall <pkg>
```

The `brew()` wrapper in `zsh/functions/brew.sh` edits
`homebrew/Brewfile.<host>`, runs `darwin-rebuild switch`, then commits and
pushes the diff. The Brewfile IS the package set — `homebrew.onActivation.cleanup
= "zap"` removes anything not declared.

## Commands cheatsheet

```sh
# Apply current config (after editing a .nix file)
sudo darwin-rebuild switch --flake ~/.config/darwin#shallot

# Rollback to the previous generation
sudo darwin-rebuild --rollback

# List all generations
darwin-rebuild --list-generations

# Switch to a specific generation
sudo /nix/var/nix/profiles/system-<N>-link/activate
```

## Principle

Write canonical declarative nix wherever possible. Escape hatches
(`system.activationScripts`, `CustomUserPreferences`) only when:

- nix-darwin has no typed option for the thing, AND
- the imperative version cannot be replaced by a typed option in a near
  future nix-darwin release without changing user-visible behavior

Every escape hatch in this directory has an inline justification comment.
If you add another, do the same.
