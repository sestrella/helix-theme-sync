{
  inputs = {
    devenv.url = "github:cachix/devenv";
    nix-filter.url = "github:numtide/nix-filter";
    nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";
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
      ...
    }@inputs:
    {
      devShells = {
        aarch64-darwin.default =
          let
            pkgs = nixpkgs.legacyPackages.aarch64-darwin;
          in
          devenv.lib.mkShell {
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
        x86_64-linux.ci =
          let
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
          in
          devenv.lib.mkShell {
            inherit inputs pkgs;

            modules = [
              {
                packages = [
                  pkgs.actionlint
                ];
              }
            ];
          };
      };

      packages.aarch64-darwin.default =
        let
          pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        in
        pkgs.callPackage ./default.nix {
          nix-filter = nix-filter.lib;
        };
    };
}
