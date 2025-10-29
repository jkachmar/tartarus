{ config, pkgs, ... }:
let
  domain = "${config.networking.hostName}.thempire.dev";
in
{

  services.plex = {
    enable = true;
    package = pkgs.plex-plexpass;
  };

  # TODO: Move this out to a separate media module or something.
  users.groups.media.gid = 1010;
  users.users.plex.extraGroups = [ "media" ];

  services.nginx.virtualHosts."plex.${domain}" = {
    useACMEHost = domain;
    http2 = true;

    locations."/" = {
      proxyPass = "http://localhost:32400";
      proxyWebsockets = true;
    };

    # NOTE: This is mostly cargo culted, probably worth reviewing and making
    # sure everything here still applies...
    extraConfig = ''
      # Some players don't reopen a socket and playback stops totally instead of resuming after an extended pause
      send_timeout 100m;

      # Plex headers
      proxy_set_header X-Plex-Client-Identifier $http_x_plex_client_identifier;
      proxy_set_header X-Plex-Device $http_x_plex_device;
      proxy_set_header X-Plex-Device-Name $http_x_plex_device_name;
      proxy_set_header X-Plex-Platform $http_x_plex_platform;
      proxy_set_header X-Plex-Platform-Version $http_x_plex_platform_version;
      proxy_set_header X-Plex-Product $http_x_plex_product;
      proxy_set_header X-Plex-Token $http_x_plex_token;
      proxy_set_header X-Plex-Version $http_x_plex_version;
      proxy_set_header X-Plex-Nocache $http_x_plex_nocache;
      proxy_set_header X-Plex-Provides $http_x_plex_provides;
      proxy_set_header X-Plex-Device-Vendor $http_x_plex_device_vendor;
      proxy_set_header X-Plex-Model $http_x_plex_model;

      # Buffering off send to the client as soon as the data is received from Plex.
      proxy_redirect off;
      proxy_buffering off;
    '';
  };

  networking.firewall = {
    allowedTCPPorts = [
      32400 # media server
      32469 # DLNA server
    ];
    allowedUDPPorts = [
      1900 # DLNA server
      32410 # GDM network discovery
      32412 # ^
      32413 # ^
      32414 # ^
    ];
  };
}
