{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkMerge [
  {
    home.stateVersion = "26.05";

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
        signing.enable = lib.mkDefault true;
      };
    };
  }
  (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    programs.emacs.enable = true;
    services.emacs = {
      enable = true;
      client.enable = true;
    };

    # 'pkgs.ghostty' doesn't build on macOS so we need to source terminfo from
    # the app bundle
    launchd.agents.emacs.config.EnvironmentVariables = {
      TERMINFO_DIRS = "/Applications/Ghostty.app/Contents/Resources/terminfo:";
    };
  })
]
