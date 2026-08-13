{ config, lib, ... }:
let
  cfg = config.profiles.darwin;
in
{
  options.profiles.darwin.apps = {
    default = (lib.mkEnableOption "general purpose darwin applications") // {
      default = true;
    };
    personal = lib.mkEnableOption "non-work darwin applications";
  };
  config = lib.mkIf cfg.enable {
    homebrew = {
      global.autoUpdate = lib.mkDefault true;
      onActivation.upgrade = lib.mkDefault true;
      casks =
        lib.optionals cfg.apps.default [
          "balenaetcher" # usb drive imaging
          "ghostty" # spooky terminal
          "sanesidebuttons" # better mouse navigation
        ]
        ++ lib.optionals cfg.apps.personal [
          "calibre" # digital library
          "discord" # nerd chat
          "element" # nerdier chat
          "signal" # secret chat
          "zotero" # nerdier digital library
        ];
      # Mac App Store applications.
      #
      # NOTE: Use the `mas` CLI to search for the number associated with a
      # given application name.
      #
      # e.g. `mas search 1Password`
      masApps = lib.mkIf cfg.apps.personal {
        # "Slack" = 803453959;
        # "Strongbox Pro" = 1481853033;
        # "Wireguard" = 1451685025;
      };
    };
  };
}
