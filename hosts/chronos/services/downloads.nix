{ config, lib, ... }:
let
  domain = "${config.networking.hostName}.thempire.dev";
  sabnzbdPort = 8081;
  radarrPort = config.services.radarr.settings.server.port;
  sonarrPort = config.services.sonarr.settings.server.port;
in
{
  services.sabnzbd.enable = true;
  services.radarr.enable = true;
  services.sonarr.enable = true;

  services.nginx.virtualHosts = {
    "nzb.${domain}" = {
      useACMEHost = domain;
      locations."/".proxyPass = "http://localhost:${builtins.toString sabnzbdPort}";
    };
    "radarr.${domain}" = {
      useACMEHost = domain;
      locations."/".proxyPass = "http://localhost:${builtins.toString radarrPort}";
    };
    "sonarr.${domain}" = {
      useACMEHost = domain;
      locations."/".proxyPass = "http://localhost:${builtins.toString sonarrPort}";
    };
  };

  sops.secrets = {
    "sabnzbd/apikey".restartUnits = [
      config.systemd.services.prometheus-sabnzbd-exporter.name
      config.systemd.services.radarr.name
      config.systemd.services.sonarr.name
    ];
    "radarr/apikey".restartUnits = [ config.systemd.services.prometheus-exportarr-radarr-exporter.name ];
    "sonarr/apikey".restartUnits = [ config.systemd.services.prometheus-exportarr-sonarr-exporter.name ];
  };

  services.prometheus.exporters = {
    exportarr-radarr = {
      url = "http://localhost:${builtins.toString radarrPort}";
      apiKeyFile = config.sops.secrets."radarr/apikey".path;
    };

    exportarr-sonarr = {
      url = "http://localhost:${builtins.toString sonarrPort}";
      apiKeyFile = config.sops.secrets."sonarr/apikey".path;
    };

    sabnzbd.servers = [
      {
        baseUrl = "http://localhost:${builtins.toString sabnzbdPort}";
        apiKeyFile = config.sops.secrets."sabnzbd/apikey".path;
      }
    ];
  };
}
