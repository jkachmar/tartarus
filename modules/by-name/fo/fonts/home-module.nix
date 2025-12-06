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
      hack-font
      ibm-plex
      jetbrains-mono
      overpass

      # Various fonts with nerd symbols.
      nerd-fonts.blex-mono
      nerd-fonts.hack
      nerd-fonts.jetbrains-mono
      nerd-fonts.overpass
      nerd-fonts.symbols-only
    ];
  };
}
