{ config, lib, ... }:
{
  # Enable the node exporter if Victoriametrics is running.
  services.prometheus.exporters.node.enable = lib.mkDefault config.services.victoriametrics.enable;
  # All servers running Victoriametrics should also scrape their own node exporter.
  services.victoriametrics.prometheusConfig.scrape_configs = [
    {
      job_name = "node";
      scrape_interval = "1m";
      static_configs = [
        { targets = [ "localhost:${builtins.toString config.services.prometheus.exporters.node.port}" ]; }
      ];
    }
  ];
}
