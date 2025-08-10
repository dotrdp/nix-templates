{
  stdenv,
  swift,
  swiftpm,
  swiftpm2nix,
  fetchFromGitHub,
}:

let
  # Pass the generated files to the helper.
  generated = swiftpm2nix.helpers ./nix;

in
stdenv.mkDerivation (finalAttrs: {
  pname = "myproject";
  version = "0.0.0";

  src = fetchFromGitHub {
    owner = "nixos";
    repo = "myproject";
    tag = finalAttrs.version;
    hash = "";
  };

  # Including SwiftPM as a nativeBuildInput provides a buildPhase for you.
  # This by default performs a release build using SwiftPM, essentially:
  #   swift build -c release
  nativeBuildInputs = [
    swift
    swiftpm
  ];

  # The helper provides a configure snippet that will prepare all dependencies
  # in the correct place, where SwiftPM expects them.
  configurePhase = generated.configure;

  installPhase = ''
    runHook preInstall

    # This is a special function that invokes swiftpm to find the location
    # of the binaries it produced.
    binPath="$(swiftpmBinPath)"
    # Now perform any installation steps.
    mkdir -p $out/bin
    cp $binPath/myproject $out/bin/

    runHook postInstall
  '';
})
