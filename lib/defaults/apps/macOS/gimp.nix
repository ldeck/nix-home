{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.macOS.apps.gimp;
  arch = if stdenv.isDarwin stdenv.hostPlatform.darwinArch else stdenv.system;
  toHyphenedLower = str:
    (lib.strings.toLower (builtins.replaceStrings [" "] ["-"] str));
in {
  options = {
    macOS.apps.gimp = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      sourceRoot = mkOption {
        default = "GIMP-2.10.app";
        description = "The app folder name to recursively copy from the install archive. e.g., Foo.app";
      };
      version = mkOption {
        default = "2.10.30";
        description = "The version of the app.";
      };
      sha256 = mkOption {
        default = "6f9e0384882bc176699e4f85950971c264c21328d98226f8c7fe9da7e55b932c";
        description = "The sha256 for the app.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages =
      (pkgs.callPackage ./lib/app.nix rec {
        name = "Gimp";
        description = "Free and open-source image editor";
        sourceRoot = cfg.sourceRoot;
        version = cfg.version;
        src = pkgs.fetchurl {
          url = "https://download.gimp.org/pub/gimp/v${lib.versions.majorMinor cfg.version}/osx/gimp-${cfg.version}-x86_64.dmg";
          sha256 = cfg.sha256;
          name = "${(toHyphenedLower name)}-${arch}-${version}.dmg";
        };
        appcast = "https://formulae.brew.sh/api/cask/gimp.json";
        homepage = "https://www.gimp.org/";
      });
  };
}
