{
  config,
  lib,
  unstable,
  ...
}:
let
  cfg = config.services.sonarr;
  promCfg = config.services.prometheus.exporters.exportarr-sonarr;
  vmCfg = config.services.victoriametrics;
in
lib.mkIf cfg.enable {
  services.sonarr = {
    package = unstable.sonarr;
    group = "downloads";
  };

  services.prometheus.exporters.exportarr-sonarr.enable = lib.mkDefault (cfg.enable && vmCfg.enable);
  services.victoriametrics.prometheusConfig.scrape_configs = lib.mkIf promCfg.enable [
    {
      job_name = "sonarr";
      scrape_interval = "1m";
      static_configs = [
        { targets = [ "localhost:${builtins.toString promCfg.port}" ]; }
      ];
    }
  ];
}
