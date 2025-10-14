{ config, ... }:
let
  domain = "${config.networking.hostName}.thempire.dev";
  port = 8428;
in
{
  services = {
    victoriametrics = {
      enable = true;
      listenAddress = ":${builtins.toString port}";
      retentionPeriod = "15d";
    };
    nginx.virtualHosts."nike.${domain}" = {
      useACMEHost = domain;
      locations."/".proxyPass = "http://localhost:${builtins.toString port}";
    };
  };
}
