{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.fonts;
in
{
  options.fonts.installDefaultFonts = lib.mkEnableOption "Install some commonly used fonts.";
  config = lib.mkIf cfg.installDefaultFonts {
    home.packages = with pkgs; [
      # Icon fonts.
      emacs-all-the-icons-fonts
      font-awesome_5

      # "Actual" fonts.
      ibm-plex

      # Various fonts with nerd symbols.
      nerd-fonts.blex-mono
      nerd-fonts.symbols-only
    ];
  };
}
