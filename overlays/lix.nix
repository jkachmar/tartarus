final: prev:
let
  lixOverride = {
    nix = final.lixPackageSets.latest.lix;
  };
in
{
  colmena = prev.colmena.override lixOverride;
  nix-direnv = prev.nix-direnv.override lixOverride;
  nix-eval-jobs = prev.lixPackageSets.latest.nix-eval-jobs;
  nix-fast-build = prev.nix-fast-build.override lixOverride;
  nixpkgs-review = prev.nixpkgs-review.override lixOverride;
  nixos-rebuild-ng = prev.nixos-rebuild-ng.override lixOverride;
}
