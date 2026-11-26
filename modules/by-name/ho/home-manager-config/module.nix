{
  inputs,
  lib,
  self,
  unstable,
  ...
}:
{
  home-manager = {
    extraSpecialArgs = { inherit inputs self unstable; };
    useGlobalPkgs = lib.mkDefault true;
  };
}
