{
  inputs = {
    nix-filter.url = "github:numtide/nix-filter";
    nixpkgs.url = "github:nixos/nixpkgs";
    systems.url = "github:nix-systems/default-darwin";
  };

  outputs =
    {
      nix-filter,
      nixpkgs,
      systems,
      ...
    }:
    {
      packages = nixpkgs.lib.genAttrs (import systems) (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.callPackage ./default.nix { nix-filter = nix-filter.lib; };
        }
      );
    };
}
