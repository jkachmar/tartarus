{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.profiles.server.nginx;
in
{
  options.profiles.server.nginx.enable = lib.mkEnableOption "nginx web server profile";

  # override default virtual host submodule options.
  options.services.nginx.virtualHosts = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        config = {
          forceSSL = lib.mkDefault true;
          kTLS = lib.mkDefault true;
          quic = lib.mkDefault true;
        };
      }
    );
  };

  config = lib.mkIf cfg.enable {
    services.nginx = {
      enable = true;
      enableReload = lib.mkDefault true;
      enableQuicBPF = lib.mkDefault true;
      recommendedBrotliSettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
    };
    users.users.nginx.extraGroups = [ config.users.users.acme.group ];
    networking.firewall = {
      allowedUDPPorts = [
        80
        443
      ];
      allowedTCPPorts = [
        80
        443
      ];
    };
  };
}
