{
  inputs,
  pkgs,
  unstable,
  ...
}:

{
  nix = {
    package = unstable.lixPackageSets.lix_2_96.lix;
    settings = {
      experimental-features = [
        "flakes"
        "nix-command"
      ];
      allowed-users = [ "root" ];
    };
    channel.enable = false;
  };
}
