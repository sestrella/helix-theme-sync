{
  nix-filter,
  stdenv,
  swift,
  swiftpm,
  swiftpm2nix,
}:

let
  generated = swiftpm2nix.helpers ./nix;
in
stdenv.mkDerivation rec {
  pname = "helix-theme-sync";
  version = "0.1.0";

  src = nix-filter {
    root = ./.;
    include = [
      "Package.resolved"
      "Package.swift"
      "Sources"
    ];
  };

  nativeBuildInputs = [
    swift
    swiftpm
  ];

  configurePhase = ''
    runHook preConfigure

    ${generated.configure}

    runHook postConfigure
  '';

  installPhase = ''
    runHook preInstall

    binPath="$(swiftpmBinPath)"
    mkdir -p $out/bin
    cp $binPath/${pname} $out/bin/

    runHook postInstall
  '';

  meta.mainProgram = pname;
}
