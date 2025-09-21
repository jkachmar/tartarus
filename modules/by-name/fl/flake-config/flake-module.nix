{ inputs, self, ... }:

{
  perSystem =
    { system, unstable, ... }:
    {
      _module.args = {
        pkgs = import inputs.nixpkgs {
          inherit system;
          config = self.nixpkgs-config;
          overlays = [
            self.overlays.stable
            self.overlays.lix
          ];
        };
        unstable = import inputs.unstable {
          inherit system;
          config = self.nixpkgs-config;
          overlays = [
            self.overlays.unstable
            self.overlays.lix
          ];
        };
      };
    };
}
