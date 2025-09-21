{ inputs, ... }:
{
  imports = [ inputs.sops-nix.darwinModules.default ];
}
