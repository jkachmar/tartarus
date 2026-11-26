{
  config,
  osConfig,
  inputs,
  lib,
  self,
  ...
}:
let
  defaultSopsPath = "${self}/hosts/${osConfig.networking.hostName}/secrets.yaml";
in
{
  imports = [ inputs.sops-nix.homeModules.default ];
  sops.defaultSopsFile = lib.mkIf (builtins.pathExists defaultSopsPath) defaultSopsPath;
}
