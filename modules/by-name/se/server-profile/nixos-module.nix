{ config, lib, pkgs, ... }:
let
  cfg = config.profiles.server;
in
{
  options.profiles.server.enable = lib.mkEnableOption "server profile";

  config = lib.mkIf cfg.enable {
    # Always clear 'tmp' on boot.
    boot = {
      tmp = {
        cleanOnBoot = lib.mkDefault true;
        useTmpfs = lib.mkDefault true;
        tmpfsSize = lib.mkDefault "8G";
      };

      loader = {
        # Use the systemd-boot EFI boot loader by default.
        systemd-boot = {
          enable = lib.mkDefault true;
          # Don't keep more than 32 old configurations, to keep the '/boot'
          # partition from filling up.
          configurationLimit = lib.mkDefault 32;
        };

        efi.canTouchEfiVariables = lib.mkDefault true;
      };
    };

    # Don't install the '/lib/ld-linux.so.2 stub'; saves one instance of nixpkgs.
    environment.ldso32 = null;
    environment.systemPackages = with pkgs; [
      ghostty.terminfo
    ];

    # Use 'dbus-broker' impl; it's better than the default.
    #
    # Can be removed once 'dbus-broker' is the default impl.
    # cf. https://github.com/NixOS/nixpkgs/issues/299476
    services.dbus.implementation = "broker";

    # All these systems have at least one SSD.
    services.fstrim.enable = lib.mkDefault true;

    # Use Rust-based system switcher.
    system.switch = {
      enable = lib.mkDefault false;
      enableNg = lib.mkDefault true;
    };

    # By default we want all NixOS hosts to manage users declaratively.
    users.mutableUsers = lib.mkDefault false;

    networking = {
      firewall.enable = lib.mkDefault true;
      nftables.enable = lib.mkDefault true;
    };

    services = {
      fail2ban.enable = lib.mkDefault false;
      openssh.enable = lib.mkDefault true;
      smartd.enable = lib.mkDefault true;
    };

    zramSwap.enable = true;
  };
}
