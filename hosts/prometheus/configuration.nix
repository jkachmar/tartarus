{
  config,
  lib,
  self,
  ...
}:

{
  imports = [
    # my personal user declaration & associated home-manager config.
    self.darwinModules.jkachmar
  ];

  networking.hostName = "prometheus";
  home-manager.users.jkachmar.profiles.vcs.email = "j@mercury.com";

  nix.linux-builder = {
    enable = true;
    maxJobs = 4;
    config = {
      virtualisation = {
        cores = 6;
          darwin-builder.memorySize = 12 * 1024;
          darwin-builder.diskSize = 60 * 1024;
        };
      };
    };
  nix.settings.trusted-users = [ "@admin" ];

  system = {
    primaryUser = "jkachmar";
    stateVersion = 6;
  };
}
