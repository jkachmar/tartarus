# adapted from https://github.com/tadfisher/flake/blob/e92fc8659ad10d694acaecea2e78cf38389c410d/pkgs/plex-plexpass/update.sh

{ lib
, stdenv
, plexRaw
, fetchurl
}:
let
  sources = builtins.fromJSON (builtins.readFile ./sources.json);
  source = lib.findFirst
    (x: x.platform == stdenv.hostPlatform.system)
    (throw "unsupported platform: ${stdenv.hostPlatform.system}")
    sources;
in
plexRaw.overrideAttrs (attrs: rec {
  pname = attrs.pname + "-plexpass";
  version = source.version;
  src = fetchurl {
    inherit (source) url;
    sha256 = source.hash;
  };
})
