{
  stdenv,
  zstd,
  tpi,
  makeWrapper,
}:
stdenv.mkDerivation {
  pname = "flashScript";
  version = "1.0.0";
  buildInputs = [zstd tpi];
  nativeBuildInputs = [makeWrapper];

  # Point to the shell script source
  src = ./flashScript.sh;
  dontUnpack = true;

  # Installation phase: Copy the script into the Nix store
  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/flashScript
    chmod +x $out/bin/flashScript
  '';
}
