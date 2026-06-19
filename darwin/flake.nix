{
  description = "nix-darwin configuration for adam's macOS hosts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-homebrew lets us declare the Brewfile contents inside nix-darwin
    # so `darwin-rebuild switch` is the only thing that installs/uninstalls
    # brew packages. Source of truth lives in ../homebrew/Brewfile.${host}.
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = { self, nixpkgs, nix-darwin, nix-homebrew }: {
    darwinConfigurations.shallot = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = { inherit nix-homebrew; };
      modules = [ ./shallot.nix ];
    };
  };
}
