{
  inputs = {
    devenv.url = "github:cachix/devenv";
    nix-filter.url = "github:numtide/nix-filter";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  nixConfig = {
    extra-substituters = "https://devenv.cachix.org";
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
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
                  pkgs.actionlint
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
