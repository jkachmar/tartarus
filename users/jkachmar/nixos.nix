{ config, ... }:
let
  username = "jkachmar";
in
{
  imports = [ ./configuration.nix ];

  security.ssh-agent.enable = true;

  users.users.${username} = {
    name = username;
    uid = 1000;
    extraGroups = [ "wheel" ];
    isNormalUser = true;
    hashedPassword = "$y$j9T$tKbi4gllRzzbgh2p1Wd6N/$Pc0Ae3q81nXmKV3GsFIIbC345Rmf4KZTDjrsw982Lj3";
    openssh.authorizedKeys.keys = [
      # yubikey
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKZJVgzxzU87/KHzc8u+RZot1/CHyW85zSC5jdlbDDUx openpgp:0xAAF3634A"
    ];
  };
  users.groups.${username}.gid = 1000;
  nix.settings = {
    allowed-users = [ username ];
    trusted-users = [ username ];
  };
}
