{
  config,
  lib,
  pkgs,
  unstable,
  ...
}:
let
  cfg = config.profiles.vcs;
  homeCfg = config.home;
in
{
  options.profiles.vcs = {
    enable = lib.mkEnableOption "version control system profile";

    name = lib.mkOption {
      type = lib.types.str;
      default = "jkachmar";
      description = "default VCS name (appears on commits)";
    };

    email = lib.mkOption {
      type = lib.types.str;
      default = "git@jkachmar.com";
      description = "my default VCS email address (appears on commits)";
    };

    signing = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "commit signing with gpg; defaults to keys associated with vcs email";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      programs.git = {
        enable = true;

        settings = {
          user.name = cfg.name;
          user.email = cfg.email;
          init.defaultBranch = "main";
          pull.rebase = true;
          push.default = "simple";
          rerere.enabled = true;
        };

        # 'home-manager' is handling git config, so make sure jujutsu's state
        # directory is ignored when colocated with git repos.
        ignores = [ ".jj" ];
      };

      # Install 'watchman' so 'jujutsu' can use it for filesystem monitoring.
      home.packages = [ pkgs.watchman ];
      programs.jujutsu = {
        enable = true;
        # XXX: cargo-nextest fails to build on macOS, skip tests until the issue
        # is resolved.
        #
        # cf. https://github.com/NixOS/nixpkgs/issues/456113
        package = unstable.jujutsu;
        settings = {
          user.name = cfg.name;
          user.email = cfg.email;

          git = {
            push-new-bookmarks = true;
            write-change-id-header = true;
          };

          # FIXME: Weird performance regression with `watchman`.
          # cf. https://github.com/jj-vcs/jj/issues/5826
          #
          # core.fsmonitor = "watchman";
          colors."commit_id prefix".bold = true;
          template-aliases."format_short_id(id)" = "id.shortest(12)";

          # FIXME: NixOS & nix-darwin both set '$PAGER' to 'less -R'.
          ui = {
            pager = "less \-FRX";
            show-cryptographic-signatures = true;
          };

          # Cribbed the following from Jonathan.
          revsets = {
            log = "@ | bases | working_lineage | base_branches | base_heads | base_roots";
          };

          revset-aliases = {
            bases = "present(bookmarks(base)) | trunk()";
            working_lineage = "bases::@ | @::";
            base_branches = "bases:: & bookmarks() & mine()";
            base_heads = "heads(bases::) & mine()";
            base_roots = "roots(bases:: ~ bases) & mine()";
            "base_to_branch(target)" = "bases::bookmarks(target) ~ bases";
          };

          aliases = {
            l = [ "log" ];
            ll = [
              "log"
              "-r"
              "all()"
              "-n"
              "10"
            ];
            lc = [
              "log"
              "-r"
              "::@"
              "-l"
              "10"
            ];
            s = [ "status" ];
            n = [
              "new"
              "-r"
              "base"
            ];
            f = [
              "git"
              "fetch"
            ];
            back = [
              "edit"
              "-r"
              "@-"
            ];

            # Cleanup: has a long name because it is desctructive. Abandon
            # all empty descendents of 'bases'
            cleanup = [
              "abandon"
              "bases:: ~ bases & empty()"
            ];

            rb = [
              "rebase"
              "-s"
              "base"
              "-d"
              "trunk()"
            ];

            # Log Mine: Non-graph view of the head of the 10 most recent changesets
            # that are mine
            lm = [
              "log"
              "-r"
              "heads(mine())"
              "--no-graph"
              "-n"
              "10"
            ];
          };
        };
      };
    })
    (lib.mkIf (cfg.enable && cfg.signing) {
      programs.jujutsu.settings = {
        git.sign-on-push = true;
        signing = {
          backend = "gpg";
          behavior = "own";
          key = cfg.email;
        };
      };
    })
  ];
}
