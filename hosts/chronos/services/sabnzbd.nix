{ config, lib, ... }:
let
  domain = "${config.networking.hostName}.thempire.dev";
  promCfg = config.services.prometheus.exporters.sabnzbd;
  port = 8081;
in
{
  services.nginx.virtualHosts."nzb.${domain}" = {
    useACMEHost = domain;
    locations = {
      "/".proxyPass = "http://localhost:${builtins.toString port}";
    };
  };

  sops.secrets."sabnzbd/apikey" = {
    restartUnits = [ config.systemd.services.prometheus-sabnzbd-exporter.name ];
  };
  services.prometheus.exporters.sabnzbd.servers = [
    {
      baseUrl = "http://localhost:${builtins.toString port}";
      apiKeyFile = config.sops.secrets."sabnzbd/apikey".path;
    }
  ];
}
