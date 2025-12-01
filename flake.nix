{
  description = "";

  outputs =
    inputs@{ flake-parts, ... }:
    let
      modules = import ./modules/top-level/all-modules.nix { inherit (inputs.nixpkgs) lib; };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      imports = modules.flake ++ [
        ./users/jkachmar
        ./hosts/chronos
        ./hosts/moros
        ./hosts/prometheus
      ];

      flake = {
        # Expose the default nixpkgs config that's shared by all package sets.
        nixpkgs-config = {
          allowUnfree = true;
        };
        # Expose different overlays for the 'stable' & 'unstable' package sets.
        overlays = {
          lix = import ./overlays/lix.nix;
          stable = import ./overlays/stable.nix;
          unstable = import ./overlays/unstable.nix;
        };
        # implementation details meant for internal consumption.
        internal = {
          # re-expose non-flake modules so they can be imported from within
          # the configuration.
          modules = {
            inherit (modules) darwin nixos home;
          };
        };
      };
    };

  inputs = {
    # Package sets.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable-small";

    # macOS system management.
    darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # User config management.
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Flake module management.
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # Autoformatting via 'nix fmt'.
    treefmt = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:numtide/treefmt-nix";
    };

    # Partition management.
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secret management.
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # A cute theme for lots of stuff :3
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
