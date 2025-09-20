{
  nix.settings = {
    experimental-features = [ "cgroups" ];
    allowed-users = [ "@wheel" ];
    trusted-users = [ "@wheel" ];
  };

  # '/tmp' on 'tmpfs' can run out of inodes if the partition is small enough;
  # probably worth it to just use '/var/tmp', since that's supposed to be
  # semi-persistent across reboots anyway.
  systemd.services.nix-daemon = {
    environment.TMPDIR = "/var/tmp";
    # If the daemon enables '--use-cgroups' & the 'nix' package has cgroup
    # delegation support (& the daemon process moves into its own sub-group)
    # then we get some nice features (e.g. resource limits on Nix build
    # processes, the OOM-killer targeting them instead of the whole daemon)
    #
    # cf. https://github.com/NixOS/nix/issues/9675
    #     https://github.com/NixOS/nix/pull/11414
    #
    # serviceConfig.ExecStart = "${config.nix.package.out}/bin/nix-daemon --daemon --use-cgroups";
  };
}
