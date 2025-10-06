{ pkgs, ... }: {

  services.plex = {
    enable = true;
    package = pkgs.plex-plexpass;
  };

  # TODO: Move this out to a separate media module or something.
  users.groups.media.gid = 1010;
  users.users.plex.extraGroups = [ "media" ];

  # FIXME: reverse proxy these behind nginx & close the ports off.
  networking.firewall = {
    allowedTCPPorts = [
      32400
      3005
      8324
      32469
    ];
    allowedUDPPorts = [
      1900
      5353
      32410
      32412
      32413
      32414
    ];
  };
}
