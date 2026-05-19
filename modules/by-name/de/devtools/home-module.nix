{
  config,
  inputs,
  lib,
  pkgs,
  unstable,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;

  cfg = config.profiles.devtools;

  gcoreutils = pkgs.coreutils.override {
    singleBinary = false;
    withPrefix = true;
  };
in
{
  options.profiles.devtools.enable = lib.mkEnableOption "common developer tools";

  config = lib.mkIf cfg.enable {
    home.packages =
      with pkgs;
      [
        curl
        rsync
        wget
      ]
      ++ lib.optionals isDarwin [
        findutils
        gcoreutils
      ];

    programs = {
      bash.enable = true;
      zsh.enable = true;
      fish = {
        enable = true;
        shellInit = ''
          set -g fish_greeting
          fish_vi_key_bindings
        '';
      };

      helix = {
        enable = true;
        package = unstable.helix;
        defaultEditor = true;
        settings.theme = "gruvbox_light";
      };

      bat = {
        enable = true;
        config.theme = "gruvbox-light";
      };
      btop.enable = true;
      fd.enable = true;
      git.enable = true;
      jq.enable = true;
      ripgrep.enable = true;

      direnv = {
        enable = true;
        # broken on 25.11 stable for now
        #
        # cf. https://github.com/NixOS/nixpkgs/issues/502464
        package = unstable.direnv;
        nix-direnv.enable = true;
      };

      fzf = {
        enable = true;
        tmux.enableShellIntegration = true;
      };

      tmux = {
        enable = true;
        clock24 = true;
        keyMode = "vi";
        # FIXME: re-enable this once https://github.com/tmux-plugins/tmux-sensible/pull/75 is closed
        sensibleOnTop = false;
        shell = "${lib.getExe config.programs.fish.package}";
      };

      starship = {
        enable = true;
        settings = {
          add_newline = false;
          line_break.disabled = true;
          username.show_always = true;
        };
      };
    };
  };
}
