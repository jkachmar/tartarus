{
  networking = {
    useDHCP = false; # set everything up via 'systemd.network'
    dhcpcd.enable = false; # use 'systemd-resolved' instead
  };

  systemd.network = {
    enable = true;
    wait-online.anyInterface = true;
    netdevs."10-bond0" = {
      netdevConfig = {
        Name = "bond0";
        Kind = "bond";
      };
      bondConfig = {
        Mode = "802.3ad";
        TransmitHashPolicy = "layer3+4";
        MIIMonitorSec = "100ms";
        LACPTransmitRate = "fast";
      };
    };
    networks = {
      "10-eno1" = {
        matchConfig.Name = "eno1";
        networkConfig.Bond = "bond0";
      };
      "10-eno2" = {
        matchConfig.Name = "eno2";
        networkConfig.Bond = "bond0";
      };
      "20-bond0" = {
        matchConfig.Name = "bond0";
        networkConfig = {
          DHCP = "yes";
          MulticastDNS = true;
        };
        linkConfig.RequiredForOnline = "carrier";
      };
    };
  };

  # Multicast DNS needs UDP port 5353 opened up for resolution.
  #
  # TODO: Move this into some base profile settings for bare-metal servers.
  networking.firewall.allowedUDPPorts = [ 5353 ];
  services.resolved = {
    enable = true;
    settings.Resolve.FallbackDNS = [
      "9.9.9.9"
      "8.8.8.8"
    ];
  };
}
