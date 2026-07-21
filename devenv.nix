{ lib, pkgs, ... }:

{
  packages = [
    pkgs.swiftpm
    pkgs.swiftpm2nix
  ];

  languages.swift.enable = true;

  git-hooks.hooks.swiftpm2nix = {
    enable = true;

    entry = lib.getExe pkgs.swiftpm2nix;
    files = "Package.swift";
  };
}
