{
  config,
  inputs,
  lib,
  pkgs,
  self,
  ...
}:

{
  imports = [
    inputs.disko.nixosModules.default
    # my personal user declaration & associated home-manager config.
    self.nixosModules.jkachmar
    # machine-specific system config.
    ./networking.nix
    ./disks
    # service config for stuff that lives on this machine.
    ./services
  ];

  profiles.server = {
    enable = true;
    nginx.enable = true;
  };

  # FIXME: This causes infinite recursion if set in the 'services/sabnzbd.nix'
  # module (because the prometheus config is dependent on the service being
  # enabled).
  #
  # Break the recursion by factoring this out to its own set of options.
  services.sabnzbd.enable = true;

  # FIXME: Set up GPG agent forwarding.
  home-manager.users.jkachmar.profiles.vcs.signing = false;

  # Secrets that are shared between a few services ('ddclient' & 'acme') &
  # should be defined once.
  sops.secrets = {
    "porkbun/apikey" = { };
    "porkbun/secretapikey" = { };
    "porkbun/domains" = { };
  };

  security.acme = {
    defaults.credentialFiles = {
      PORKBUN_API_KEY_FILE = config.sops.secrets."porkbun/apikey".path;
      PORKBUN_SECRET_API_KEY_FILE = config.sops.secrets."porkbun/secretapikey".path;
    };
    certs."chronos.thempire.dev" = {
      extraDomainNames = [ "*.chronos.thempire.dev" ];
    };
  };

  system.stateVersion = "25.05";
  networking.hostName = "chronos";

  services.smartd.devices = [
    {
      # NOTE: `DEVICESCAN` finds `/dev/nvme0`, so we should use this (rather
      # than `/dev/disk/by-id`) to make sure it doesn't get monitored twice.
      device = "/dev/nvme0";
      # Inherit default 'smartd' options, don't track incremental temperature,
      # log the temperature level at 60 C & an alert at 65 C.
      options = lib.concatStringsSep " " (
        config.services.smartd.defaults.shared
        ++ [
          "-W 0,60,65"
        ]
      );
    }
  ];

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
