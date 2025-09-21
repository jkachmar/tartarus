{ inputs, ... }:
{
  imports = [ inputs.sops-nix.nixosModules.default ];
}
