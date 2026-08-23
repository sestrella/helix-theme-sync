{ pkgs, ... }:

{
  packages = [
    pkgs.swiftpm
    pkgs.swiftpm2nix
  ];

  languages.swift.enable = true;

  git-hooks.hooks = {
    actionlint.enable = true;
    swiftpm2nix = {
      enable = true;

      entry = pkgs.lib.getExe pkgs.swiftpm2nix;
      files = "Package.swift";
    };
  };

  cachix.pull = [ "devenv" ];
}
