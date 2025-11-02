{ config, unstable, ... }:
let
  domain = "${config.networking.hostName}.thempire.dev";
  port = 6697;
  websocket = 6698;
  certDir = config.security.acme.certs.${domain}.directory;
in
{
  security.acme.certs.${domain}.reloadServices = [ config.systemd.services.soju.name ];
  networking.firewall.allowedTCPPorts = [ port ];
  services.soju = {
    enable = true;
    package = unstable.soju;
    hostName = "soju.${domain}";
    listen = [
      ":${builtins.toString port}"
      "wss://:${builtins.toString websocket}"
    ];
    tlsCertificate = "/run/credentials/soju.service/cert.pem";
    tlsCertificateKey = "/run/credentials/soju.service/key.pem";
    enableMessageLogging = true;
  };
  # XXX: Workaround systemd 'DynamicUser' & sops credentials.
  systemd.services.soju.serviceConfig.LoadCredential = [
    "cert.pem:${certDir}/cert.pem"
    "key.pem:${certDir}/key.pem"
  ];
  services.nginx.virtualHosts."irc.${domain}" = {
    useACMEHost = domain;
    locations = {
      "/".root = unstable.compressDrvWeb unstable.gamja { };
      "/socket" = {
        proxyPass = "https://localhost:${builtins.toString websocket}";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_read_timeout 600s;
        '';
      };
    };
  };
}
