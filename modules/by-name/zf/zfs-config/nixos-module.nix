{ config, lib, ... }:

{
  config = lib.mkIf config.boot.zfs.enabled {
    # Use the same default hostID as the NixOS install ISO; this allows us
    # to import the ZFS pool without using a force import.
    #
    # Uniqueness is only required for high-availability ZFS or iSCSI.
    networking.hostId = lib.mkDefault "8425e349";

    # TODO: Set up zed + email alerts on scrub errors.
    services.zfs = {
      # Enable TRIM.
      trim.enable = lib.mkDefault true;
      # Enable automatic scrubbing and snapshotting.
      autoScrub.enable = lib.mkDefault true;
      autoSnapshot = {
        enable = lib.mkDefault true;
        # -k Keep zero-sized snapshots.
        # -p Create snapshots in parallel.
        # -u Use UTC for snapshots.
        flags = lib.mkDefault "-k -p -u";
        frequent = lib.mkDefault 4;
        hourly = lib.mkDefault 24;
        daily = lib.mkDefault 3;
        weekly = lib.mkDefault 2;
        monthly = lib.mkDefault 2;
      };
    };

    # Enable the ZFS exporter if Victoriametrics is running.
    services.prometheus.exporters.zfs.enable = lib.mkDefault config.services.victoriametrics.enable;
    services.victoriametrics.prometheusConfig.scrape_configs = [
      {
        job_name = "zfs";
        scrape_interval = "1m";
        static_configs = [
          { targets = [ "localhost:${builtins.toString config.services.prometheus.exporters.zfs.port}" ]; }
        ];
      }
    ];
  };
}
