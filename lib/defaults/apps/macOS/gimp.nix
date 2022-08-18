{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.macOS.apps.gimp;
  stdenv = pkgs.stdenv;
  arch = if stdenv.isDarwin then stdenv.hostPlatform.darwinArch else stdenv.system;
  toHyphenedLower = str:
    (lib.strings.toLower (builtins.replaceStrings [" "] ["-"] str));

  archSpecs = {
    x86_64-darwin = {
      version = "2.10.32";
      revision = "";
      arch = "amd64";
      sha256 = "e5547fc01168270bd1ba5380cff610966da229e44f311138f12168cb2f34d3c8";
    };
    aarch64-darwin = {
      version = "2.10.32";
      revision = "";
      arch = "arm64";
      sha256 = "e5547fc01168270bd1ba5380cff610966da229e44f311138f12168cb2f34d3c8";
    };
  };

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
        default = archSpecs.${stdenv.hostPlatform.system}.version;
        description = "The version of the app.";
      };
      revision = mkOption {
        default = archSpecs.${stdenv.hostPlatform.system}.revision;
        description = "The build number of the app (if applicable).";
      };
      sha256 = mkOption {
        default = archSpecs.${stdenv.hostPlatform.system}.sha256;
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
