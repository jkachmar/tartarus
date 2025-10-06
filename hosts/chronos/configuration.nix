{
  config,
  inputs,
  lib,
  self,
  ...
}:

{
  imports = [
    inputs.disko.nixosModules.default
    # my personal user declaration & associated home-manager config.
    self.nixosModules.jkachmar
    # machine-specific config details.
    ./networking.nix
    ./disks/hrodreptus.nix
    ./disks/titan.nix
  ];

  profiles = {
    server.enable = true;
  };

  system.stateVersion = "25.05";
  networking.hostName = "chronos";

  # FIXME: Find a better place to refactor this out to.
  services.smartd.devices = [
    {
      # NOTE: `DEVICESCAN` finds `/dev/nvme0`, so we should use this (rather
      # than `/dev/disk/by-id`) to make sure it doesn't get monitored twice.
      device = "/dev/nvme0";
      # Inherit default 'smartd' options, but track temperature in 2 degree
      # increments with a log level at 60 C & an alert at 65 C.
      options = lib.concatStringsSep " " (
        config.services.smartd.defaults.shared
        ++ [
          "-W"
          "2,60,65"
        ]
      );
    }
  ];

  # TODO: Move this out to a separate media module or something.
  users.groups.media.gid = 1010;

  services.plex.enable = true;
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

  # Hardware survey results.
  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [ "i915" ];
    };
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  hardware.cpu.intel.updateMicrocode = true;
}
