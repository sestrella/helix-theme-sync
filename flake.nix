{
  inputs = {
    nix-filter.url = "github:numtide/nix-filter";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    {
      self,
      nix-filter,
      nixpkgs,
      ...
    }:
    {
      homeModules.default = import ./module.nix;

      packages.aarch64-darwin.default =
        let
          pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        in
        pkgs.callPackage ./default.nix {
          nix-filter = nix-filter.lib;
        };

      overlays.default = final: prev: {
        helix-theme-sync = self.packages.${prev.stdenv.hostPlatform.system}.default;
      };
    };
}
