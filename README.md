# dotfiles

The contents of my .config directory.
It includes bootstrapping functionality for use on new machines which gets me 90% of the way there.

## To run

```bash
bash ./bootstrap-darwin.sh
```

The hostname is hardcoded to `shallot` in the script. Change it there before running on a new machine.

### What the bootstrap configures

- **Sudo**: passwordless sudo for the current user
- **Hostname**: sets HostName, LocalHostName, and ComputerName to `shallot`
- **Dock**: clears default icons, enables auto-hide (no delay), disables space reordering, adds Downloads folder
- **Finder**: shows extensions and hidden files, path/status bars, list view by default, opens to home directory
- **Screenshots**: saves to `~/Pictures/Screenshots` as JPG, no window shadows
- **Trackpad**: enables tap-to-click
- **Touch ID**: enables Touch ID for sudo (`/etc/pam.d/sudo`)
- **Key repeat**: fastest repeat rate and shortest delay available in System Settings
- **Save/print panels**: expanded by default
- **Login message**: suppressed via `~/.hushlogin`
- **Packages**: installs everything in `homebrew/Brewfile` via `brew bundle`, then runs scripts in `install_scripts/`

## Highlights

### Automated Brewfile management

When you install/remove packages and casks using `brew [--cask] install/uninstall <package>` the Brewfile is automatically updated to reflect the change.

Implemented in:
- `zsh/aliases/brew.sh`
- `zsh/functions/brew.sh`
