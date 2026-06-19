{ lib }:
# Parse a Homebrew-format `Brewfile` and return the list of names declared
# with a particular keyword (e.g. "brew", "cask", "tap"). The shell wrapper
# in zsh/functions/brew.sh writes to the same Brewfile, so this gives both
# tools one shared source of truth.
#
# Expected line shapes:
#   brew "name"
#   cask "name"
#   tap  "user/repo"
#
# Lines that don't match the requested type, blank lines, comments, and
# any inline `args:` extensions are skipped. Tap-qualified formulae like
#   brew "finnvoor/tools/fx-upscale"
# pass through unchanged — nix-homebrew accepts them.
path: type:
let
  raw = lib.fileContents path;
  lines = lib.splitString "\n" raw;
  prefix = "${type} \"";
  matching = lib.filter (l: lib.hasPrefix prefix l) lines;
  stripQuotes = l:
    let
      afterPrefix = lib.removePrefix prefix l;
      # Some entries have trailing `, args: { ... }`; drop everything after
      # the closing quote of the name so the parse stays robust.
      closingQuote = lib.strings.stringLength (
        builtins.elemAt (lib.splitString "\"" afterPrefix) 0
      );
    in
    builtins.substring 0 closingQuote afterPrefix;
in
map stripQuotes matching
