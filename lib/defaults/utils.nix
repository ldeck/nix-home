{
  lib,
  stdenv,
  ...
}:

let
  nixFilesIn = dir: with builtins;
    map
      (f: "${dir}/${f}")
      (filter
        (f: lib.strings.hasSuffix ".nix" "${f}")
        (builtins.attrNames (builtins.readDir dir)));

in

{
  imports = []
            ++ (nixFilesIn ./utils/security);
}
