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
  home-manager.users.jkachmar = { config, ... }: {
    sops = {
      age.keyFile = "${config.xdg.configHome}/sops/age/moros.txt";
      secrets = {
        "storagebox/jkachmar/admin/config" = { };
        "storagebox/jkachmar/backup/config" = { };
        "storagebox/jkachmar/backup/key" = {
          path = "${config.home.homeDirectory}/.ssh/storagebox-backup";
          mode = "0400";
        };
      };
    };
    profiles.vcs.signing.identity = "0xC1782440640BC696";
    programs.ssh.includes = [
      config.sops.secrets."storagebox/jkachmar/admin/config".path
      config.sops.secrets."storagebox/jkachmar/backup/config".path
    ];
  };

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
