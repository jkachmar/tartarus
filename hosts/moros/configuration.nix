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

  # disambiguate between two gpg identities associated with my git email.
  home-manager.users.jkachmar.profiles.vcs.signing.identity = "0xC1782440640BC696";

  nix.linux-builder = {
    enable = true;
    maxJobs = 8;
    config = {
      virtualisation = {
        darwin-builder = {
          diskSize = 40 * 1024;
          memorySize = 16 * 1024;
        };
        cores = 8;
      };
    };
  };
  nix.settings.trusted-users = [ "@admin" ];

  networking.hostName = "moros";
  system = {
    primaryUser = "jkachmar";
    stateVersion = 6;
  };

  profiles = {
    darwin.apps.personal = true;
  };
}
