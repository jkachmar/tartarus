{
  config,
  lib,
  unstable,
  ...
}:
let
  cfg = config.services.sabnzbd;
  promCfg = config.services.prometheus.exporters.sabnzbd;
  vmCfg = config.services.victoriametrics;
in
lib.mkIf cfg.enable {
  users.users.sabnzbd.extraGroups = [ "downloads" ];
  services.sabnzbd.package = unstable.sabnzbd;

  systemd.services.sabnzbd.serviceConfig = lib.mkIf cfg.enable {
    NoNewPrivileges = true;
    PrivateTmp = true;
    PrivateDevices = true;
    DevicePolicy = "closed";
    ReadWritePaths = [
      "/var/cache"
      "/var/log"
    ];
    ProtectSystem = "strict";
    ProtectHome = true;
    ProtectControlGroups = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6 AF_NETLINK";
    RestrictNamespaces = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    LockPersonality = true;
  };

  services.prometheus.exporters.sabnzbd.enable = lib.mkDefault (cfg.enable && vmCfg.enable);
  services.victoriametrics.prometheusConfig.scrape_configs = lib.mkIf promCfg.enable [
    {
      job_name = "sabnzbd";
      scrape_interval = "1m";
      static_configs = [
        { targets = [ "localhost:${builtins.toString promCfg.port}" ]; }
      ];
    }
  ];
}
