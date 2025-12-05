{ config, lib, ... }:
{
  home.stateVersion = "25.11";

  fonts.installDefaultFonts = lib.mkDefault true;
  programs.gpg.enable = lib.mkDefault true;

  profiles = {
    devtools.enable = true;
    ssh = {
      enable = true;
      yubikey = true;
    };
    vcs = {
      enable = true;
      name = lib.mkDefault config.home.username;
      email = lib.mkDefault "git@jkachmar.com";
      signing = lib.mkDefault true;
    };
  };
}
