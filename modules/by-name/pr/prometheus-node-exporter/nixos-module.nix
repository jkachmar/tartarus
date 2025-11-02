{ config, lib, ... }:
let
  promCfg = config.services.prometheus.exporters.node;
  vmCfg = config.services.victoriametrics;
in
{
  # Enable the node exporter if Victoriametrics is running.
  services.prometheus.exporters.node.enable = lib.mkDefault vmCfg.enable;
  # All servers running Victoriametrics should also scrape their own node exporter.
  services.victoriametrics.prometheusConfig.scrape_configs = [
    {
      job_name = "node";
      scrape_interval = "1m";
      static_configs = [
        { targets = [ "localhost:${builtins.toString promCfg.port}" ]; }
      ];
    }
  ];
}
