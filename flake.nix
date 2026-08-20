{
  inputs = {
    devenv.url = "github:cachix/devenv";
    nix-filter.url = "github:numtide/nix-filter";
    nixpkgs.url = "github:nixos/nixpkgs";
    systems.url = "github:nix-systems/default-darwin";
  };

  outputs =
    {
      devenv,
      nix-filter,
      nixpkgs,
      systems,
      ...
    }@inputs:
    let
      forAllSystems = nixpkgs.lib.genAttrs (import systems);
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = devenv.lib.mkShell {
            inherit inputs pkgs;

            modules = [
              {
                packages = [
                  pkgs.swiftpm
                  pkgs.swiftpm2nix
                ];

                languages.swift.enable = true;

                git-hooks.hooks.swiftpm2nix = {
                  enable = true;

                  entry = pkgs.lib.getExe pkgs.swiftpm2nix;
                  files = "Package.swift";
                };
              }
            ];
          };
        }
      );

      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.callPackage ./default.nix {
            nix-filter = nix-filter.lib;
          };
        }
      );
    };
}
