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
    let
      pkgs = nixpkgs.legacyPackages.${system};
      system = "aarch64-darwin";
    in
    {
      formatter.${system} = pkgs.nixfmt-tree;

      homeModules.default = import ./module.nix;

      packages.${system}.default = pkgs.callPackage ./default.nix {
        nix-filter = nix-filter.lib;
      };

      overlays.default = final: prev: {
        helix-theme-sync = self.packages.${prev.stdenv.hostPlatform.system}.default;
      };
    };
}
