{ pkgs, lib, nix-homebrew, ... }:
let
  parseBrewfile = import ./lib/parse-brewfile.nix { inherit lib; };
  brewfile = ../homebrew/Brewfile.shallot;
in
{
  imports = [ nix-homebrew.darwinModules.nix-homebrew ];

  # ── Identity ─────────────────────────────────────────────────────────────
  # The whole reason this flake exists: an orphan nix-darwin generation was
  # rewriting HostName to "radish" on every boot, causing Tailscale to
  # register this Mac as "radish-1". Pin all three knobs so scutil agrees.
  networking.hostName = "shallot";
  networking.localHostName = "shallot";
  networking.computerName = "shallot";

  # nix-darwin schema version. Bump only when release notes tell you to.
  system.stateVersion = 6;

  # Which user owns this configuration — required for home-dir-touching
  # activation scripts (launchd user envs, screencapture location, etc).
  system.primaryUser = "adam";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # ── Sudo: passwordless + Touch ID ────────────────────────────────────────
  environment.etc."sudoers.d/adam-nopasswd".text = ''
    adam ALL=(ALL) NOPASSWD: ALL
  '';

  # Replaces the old `sed -i /etc/pam.d/sudo` hack. sudo_local survives
  # macOS upgrades; the previous in-place edit got reverted whenever Apple
  # shipped a new /etc/pam.d/sudo.
  security.pam.services.sudo_local.touchIdAuth = true;

  # ── system.defaults — ports `defaults write` calls from bootstrap.sh ─────
  system.defaults = {
    NSGlobalDomain = {
      # Fastest repeat available in System Settings UI.
      KeyRepeat = 2;
      InitialKeyRepeat = 15;

      # Expand Save/Print panels by default.
      NSNavPanelExpandedStateForSaveMode = true;
      PMPrintingExpandedStateForPrint = true;

      # Trackpad: tap-to-click.
      "com.apple.mouse.tapBehavior" = 1;

      # Match bootstrap's explicit `false` even though it's the macOS default.
      AppleShowAllExtensions = false;
    };

    dock = {
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.5;
      mru-spaces = false;
      show-recents = false;
      persistent-apps = [ ];
      # bootstrap.sh added ~/Downloads as a stack tile; nix-darwin's typed
      # form accepts just the path and renders it with the same defaults.
      persistent-others = [ "/Users/adam/Downloads" ];
    };

    finder = {
      AppleShowAllFiles = true;
      ShowPathbar = true;
      ShowStatusBar = true;
      FXPreferredViewStyle = "Nlsv";          # list view
      FXDefaultSearchScope = "SCcf";          # search current folder
      FXEnableExtensionChangeWarning = false;
      # "Home" (PfHm) makes Finder resolve the user's home automatically.
      # No NewWindowTargetPath needed — that key is only consulted when
      # NewWindowTarget = "Custom".
      NewWindowTarget = "Home";
    };

    screencapture = {
      location = "~/Pictures/Screenshots";
      type = "jpg";
      disable-shadow = true;
    };

    trackpad = {
      Clicking = true;
    };
  };

  # ── Misc activations ────────────────────────────────────────────────────
  # Silence the "Last login" banner. environment.etc owns the file so
  # nix-darwin tears it down cleanly on rollback.
  environment.etc."hushlogin".text = "";

  # Bitwarden honours this to skip its bundled Electron auto-updater.
  # Set as a launchd user env so GUI apps inherit it, not just shells.
  launchd.user.envVariables.ELECTRON_NO_UPDATER = "1";

  # Three small things live in activationScripts rather than typed
  # nix-darwin options. Each justified inline — the principle is "typed
  # option first, escape hatch only when the typed option would lie".
  #
  #   1. /etc/zshenv → live symlink into ~/.config. `environment.etc.source`
  #      would snapshot the file into the nix store; edits to .zshenv
  #      wouldn't take effect until the next `darwin-rebuild switch`.
  #      That defeats the point of having dotfiles in a git repo you
  #      iterate on. So a live symlink, declared in nix.
  #
  #   2. ~/.claude → ~/.config/claude. Claude Code hardcodes ~/.claude.
  #      Target is in $HOME, not /etc — environment.etc doesn't apply.
  #      home-manager would model this; we declined home-manager scope.
  #      Bail-out branches preserve a real ~/.claude dir for manual
  #      merge instead of silently clobbering it.
  #
  #   3. Rosetta 2. nix-darwin has no typed option. `softwareupdate
  #      --install-rosetta` is itself idempotent so re-running on every
  #      switch is cheap (no-op once installed).
  system.activationScripts.postActivation.text = ''
    set -eu

    # 1. /etc/zshenv live symlink
    /bin/rm -f /etc/zshenv
    /bin/ln -s /Users/adam/.config/zsh/.zshenv /etc/zshenv

    # 2. ~/.claude → ~/.config/claude
    home_claude="/Users/adam/.claude"
    xdg_claude="/Users/adam/.config/claude"
    mkdir -p "$xdg_claude"
    if [ -L "$home_claude" ]; then
      :
    elif [ -d "$home_claude" ]; then
      echo "warning: $home_claude is a real directory, not a symlink." >&2
      echo "  mv $home_claude $home_claude.bak && ln -s $xdg_claude $home_claude" >&2
      echo "  then merge $home_claude.bak into $xdg_claude" >&2
    else
      ln -s "$xdg_claude" "$home_claude"
    fi

    # 3. Rosetta 2 (arm64 only). `pgrep oahd` is the fast check Apple's
    # own scripts use — the alternative (`softwareupdate --install-rosetta`
    # always) re-queries Apple's update servers even when Rosetta is
    # already installed, adding seconds to every darwin-rebuild switch.
    if [ "$(uname -m)" = "arm64" ] && ! /usr/bin/pgrep -q oahd; then
      softwareupdate --install-rosetta --agree-to-license || true
    fi
  '';

  # ── Homebrew (declarative) ───────────────────────────────────────────────
  # The Brewfile at ../homebrew/Brewfile.shallot is the source of truth.
  # `zsh/functions/brew.sh` edits that file + runs `darwin-rebuild switch`,
  # so `brew install x` becomes "edit-then-converge" instead of imperative.
  #
  # `cleanup = "zap"` removes anything not declared, which is what makes
  # the Brewfile authoritative. If you `command brew install` something
  # behind the wrapper's back, the next switch will zap it.
  nix-homebrew = {
    enable = true;
    enableRosetta = false;
    user = "adam";
    autoMigrate = true;
  };

  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "zap";
      autoUpdate = false;
      upgrade = false;
    };
    brews = parseBrewfile brewfile "brew";
    casks = parseBrewfile brewfile "cask";
    taps  = parseBrewfile brewfile "tap";
  };
}
