#! /usr/bin/env nix-shell
#! nix-shell -i sh -p sops

sops exec-env overlays/plexpass/secrets.yaml overlays/plexpass/update.sh
