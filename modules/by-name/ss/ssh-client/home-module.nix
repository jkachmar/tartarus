{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs.stdenv.targetPlatform) isDarwin;
  cfg = config.profiles.ssh;
in
{
  options.profiles.ssh = {
    enable = lib.mkEnableOption "SSH user profile";
    yubikey = lib.mkEnableOption "yubikey identity file";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      programs.ssh.enable = true;
      programs.ssh.enableDefaultConfig = false;
    })
    (lib.mkIf cfg.yubikey {
      programs.ssh.matchBlocks."*".identityFile = "~/.ssh/yubikey.pub";
    })
    (lib.mkIf (cfg.enable && isDarwin) {
      programs.ssh.matchBlocks."*".addKeysToAgent = "yes";
    })
  ];
}
