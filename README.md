# dotfiles

The contents of my .config directory.
It includes a bootstrapping functionality for use on new machines which gets me 90% of the way there.

## Highlights

### Automated Brewfile management
When you install/remove packages and casks using `brew [--cask] install/uninstall <package>` the Brewfile is automatically updated to reflect this change.


This is implemented over the following files:
- `zsh/aliases/brew.sh`
- `zsh/functions/brew.sh`

## To run

```bash
bash ./bootstrap-darwin.sh <hostname>
```