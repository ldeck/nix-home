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
  pkg-config,
  ...
}:

let
  native-undmg = pkgs.writeShellScriptBin "native-undmg" ''
    if ! [[ "$src" =~ \.dmg$ ]]; then return 1; fi
    mnt="/Volumes/$RANDOM$RANDOM"
    function finish {
      echo "Detaching $mnt"
      /usr/bin/hdiutil detach $mnt -force
    }
    trap finish EXIT

    /usr/bin/hdiutil attach -nobrowse -readonly $src -mountroot $mnt
    echo "Attaching $mnt"
    cp -a $mnt/. .
  '';

in

if stdenv.isDarwin then
  [(stdenv.mkDerivation {
    name = "${name}-${version}";
    version = "${version}";
    src = src;
    buildInputs = [ unzip ];
    unpackCmd = ''
      echo "File to unpack: $curSrc"
      if ! [[ "$curSrc" =~ \.dmg$ ]]; then return 1; fi
      mnt=$(mktemp -d -t ci-XXXXXXXXXX)

      function finish {
        echo "Detaching $mnt"
        /usr/bin/hdiutil detach $mnt -force
        rm -rf $mnt
      }
      trap finish EXIT

      echo "Attaching $mnt"
      /usr/bin/hdiutil attach -nobrowse -readonly $src -mountpoint $mnt

      echo "What's in the mount dir"?
      ls -la $mnt/

      echo "Copying contents"
      shopt -s extglob
      DEST="$PWD"
      (cd "$mnt"; cp -a !(Applications) "$DEST/")
    '';
    sourceRoot = sourceRoot;
    phases = [ "unpackPhase" "installPhase" ];
    installPhase = ''
      mkdir -p "$out/Applications/${appname}.app"
      cp -a ./. "$out/Applications/${appname}.app/"
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
