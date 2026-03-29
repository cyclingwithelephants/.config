# dotfiles

The contents of my .config directory.
It includes bootstrapping functionality for use on new machines which gets me 90% of the way there.

## To run

```bash
bash ./bootstrap/bootstrap.sh
```

You can also pass a machine name explicitly:

```bash
bash ./bootstrap/bootstrap.sh radish
```

If no machine name is passed, the bootstrap script detects the current hostname and looks for a matching config file in `bootstrap/config/`. If no matching config exists, it exits with an error.

### What the bootstrap configures

- **Sudo**: passwordless sudo for the current user
- **Hostname**: sets HostName, LocalHostName, and ComputerName from the selected machine config
- **Dock**: clears default icons, enables auto-hide (no delay), disables space reordering, adds Downloads folder
- **Finder**: shows extensions and hidden files, path/status bars, list view by default, opens to home directory
- **Screenshots**: saves to `~/Pictures/Screenshots` as JPG, no window shadows
- **Trackpad**: enables tap-to-click
- **Touch ID**: enables Touch ID for sudo (`/etc/pam.d/sudo`)
- **Key repeat**: fastest repeat rate and shortest delay available in System Settings
- **Save/print panels**: expanded by default
- **Login message**: suppressed via `~/.hushlogin`
- **Packages**: installs everything in `homebrew/Brewfile` via `brew bundle`, then runs scripts in `install_scripts/`

### Configure sharing services manually

Some macOS sharing services now require privacy permissions that are awkward or unreliable to automate from a shell script. After running the bootstrap, enable these manually in System Settings if you want them:

- **Remote Login (SSH)**: `System Settings > General > Sharing > Remote Login`
- **Remote Management**: `System Settings > General > Sharing > Remote Management`
- **Content Caching**: `System Settings > General > Sharing > Content Caching`

In particular, `systemsetup -setremotelogin on` can require Full Disk Access for the terminal app running the bootstrap, so this is documented instead of automated.

## Highlights

### Automated Brewfile management

When you install/remove packages and casks using `brew [--cask] install/uninstall <package>` the Brewfile is automatically updated to reflect the change.

Implemented in:
- `zsh/aliases/brew.sh`
- `zsh/functions/brew.sh`
