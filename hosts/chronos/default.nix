{
  inputs,
  lib,
  self,
  withSystem,
  ...
}:
{
  flake.diskoConfigurations = {
    hrodreptus = import ./disks/hrodreptus.nix;
    titan = import ./disks/titan.nix;
  };
  flake.nixosConfigurations.chronos = withSystem "x86_64-linux" (
    { unstable, system, ... }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs self unstable; };
      modules = self.internal.modules.nixos ++ [
        { nixpkgs.hostPlatform = system; }
        ./configuration.nix
      ];
    }
  );
}
