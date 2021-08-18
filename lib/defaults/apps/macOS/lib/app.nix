{
  # custom args
  name,
  appname ? name,
  version,
  src,
  description,
  homepage,
  postInstall ? "",
  sourceRoot ? ".",
  # nix supplied
  pkgs,
  stdenv,
  lib,
  undmg,
  unzip,
  ...
}:

if stdenv.isDarwin then
  [(stdenv.mkDerivation {
    name = "${name}-${version}";
    version = "${version}";
    src = src;
    buildInputs = [ undmg unzip ];
    sourceRoot = sourceRoot;
    phases = [ "unpackPhase" "installPhase" ];
    installPhase = ''
      mkdir -p "$out/Applications/${appname}.app"
      cp -pR * "$out/Applications/${appname}.app"
    '' + postInstall;
    meta = {
      description = description;
      homepage = homepage;
      maintainers = [ "ldeck <ldeck@example.com>" ];
      platforms = lib.platforms.darwin;
    };
  })]
else
  []
