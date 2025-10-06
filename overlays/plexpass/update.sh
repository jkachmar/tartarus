#!/usr/bin/env bash

# adapted from https://github.com/tadfisher/flake/blob/e92fc8659ad10d694acaecea2e78cf38389c410d/pkgs/plex-plexpass/update.sh

shopt -s extglob
set -eu -o pipefail

root="$(jj root)"
path="$(realpath "$(dirname "$0")")"

declare -A platforms=(
    [linux-x86_64]=x86_64-linux
    [linux-aarch64]=aarch64-linux
)

manifest=$(curl -s "https://plex.tv/api/downloads/5.json?channel=plexpass" -H "X-Plex-Token: ${plex_token}")
version=$(echo "$manifest" | jq -r '.computer.Linux.version | split("-") | .[0]')

tmp="$path/sources.tmp.json"
echo '' > $tmp

for arch in "${!platforms[@]}"; do
  url="$(echo "$manifest" | jq --arg arch "$arch" -r '.computer.Linux.releases[] | select(.distro == "debian" and .build == $arch) .url')"
  hash="$(nix-prefetch-url "$url")"
  nixPlatform=${platforms[$arch]}
  jq --arg version $version \
     --arg platform $nixPlatform \
     --arg url "$url" \
     --arg hash $hash \
     -n '$ARGS.named' >> $tmp
done

jq -s '.' $tmp > "$path/sources.json"
rm $tmp
