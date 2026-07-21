{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    systems.url = "github:nix-systems/default-darwin";
  };

  outputs = { nixpkgs, systems, ... }: {
    packages = nixpkgs.lib.genAttrs (import systems) (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        default = pkgs.callPackage ./default.nix { };
      }
    );
  };
}
