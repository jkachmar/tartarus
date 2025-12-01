{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  gpgPkg = config.programs.gpg.package;
  cfg = config.programs.gpg;
in
{
  config = lib.mkIf (cfg.enable && isDarwin) {
    # Workaround for https://github.com/nix-community/home-manager/pull/5901
    programs.fish.shellInit = ''
      set -gx GPG_TTY (tty)

      # SSH agent protocol doesn't support changing TTYs, so bind the agent
      # to every new TTY.
      ${gpgPkg}/bin/gpg-connect-agent --quiet updatestartuptty /bye > /dev/null 2>&1

      set -e SSH_AGENT_PID
      set -e SSH_AUTH_SOCK
      set -gx SSH_AUTH_SOCK (${gpgPkg}/bin/gpgconf --list-dirs agent-ssh-socket)
    '';
  };
}
