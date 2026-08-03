{ ... }: {
  imports = [ ./configuration.nix ];

  profiles = {
    darwin.enable = true;
  };
}
