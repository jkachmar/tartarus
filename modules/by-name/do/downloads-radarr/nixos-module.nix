{
  config,
  lib,
  unstable,
  ...
}:
let
  cfg = config.services.radarr;
  promCfg = config.services.prometheus.exporters.exportarr-radarr;
  vmCfg = config.services.victoriametrics;
in
lib.mkIf cfg.enable {
  services.radarr = {
    package = unstable.radarr;
    group = "downloads";
  };

  services.prometheus.exporters.exportarr-radarr = {
    enable = lib.mkDefault (cfg.enable && vmCfg.enable);
    # XXX: So the 'exportarr' module sets '9708' as the default port for all
    # generated scraping processes which collides if you run more than one...
    port = lib.mkDefault 9709;
  };
  services.victoriametrics.prometheusConfig.scrape_configs = lib.mkIf promCfg.enable [
    {
      job_name = "radarr";
      scrape_interval = "1m";
      static_configs = [
        { targets = [ "localhost:${builtins.toString promCfg.port}" ]; }
      ];
    }
  ];
}
