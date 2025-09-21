{
  config,
  self,
  lib,
  ...
}:
let
  defaultSopsPath = "${self}/hosts/${config.networking.hostName}/secrets.yaml";
in
{
  sops.defaultSopsFile = lib.mkIf (builtins.pathExists defaultSopsPath) defaultSopsPath;
}
