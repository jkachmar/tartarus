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

  imports = [ inputs.catppuccin.homeModules.catppuccin ];

  config = lib.mkIf cfg.enable {
    # Enable catppuccin themes for all programs that have options :3
    catppuccin = {
      enable = true;
      flavor = "mocha";
    };

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
      };

      bat.enable = true;
      btop.enable = true;
      fd.enable = true;
      git.enable = true;
      jq.enable = true;
      ripgrep.enable = true;

      direnv = {
        enable = true;
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
