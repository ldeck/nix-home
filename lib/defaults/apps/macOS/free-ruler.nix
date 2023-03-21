{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.macOS.apps.free-ruler;
  stdenv = pkgs.stdenv;
  arch = if stdenv.isDarwin then stdenv.hostPlatform.darwinArch else stdenv.system;
  toHyphenedLower = str:
    (lib.strings.toLower (builtins.replaceStrings [" "] ["-"] str));

  archSpecs = {
    x86_64-darwin = {
      version = "2.0.5";
      revision = "";
      date = "";
      arch = "amd64";
      url = "https://github.com/pascalpp/FreeRuler/releases/download/v${cfg.version}/free-ruler-${cfg.version}.zip";
      sha256 = "6332b9252a4fc58dbf4a5f74b5484d6ae20c2f4cb7db7a2c86020454fa66444d";
    };
    aarch64-darwin = {
      version = "2.0.5";
      revision = "";
      date = "";
      arch = "arm64";
      url = "https://github.com/pascalpp/FreeRuler/releases/download/v${cfg.version}/free-ruler-${cfg.version}.zip";
      sha256 = "6332b9252a4fc58dbf4a5f74b5484d6ae20c2f4cb7db7a2c86020454fa66444d";
    };
  };

in {
  options = {
    macOS.apps.free-ruler = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      sourceRoot = mkOption {
        default = "Free Ruler.app";
        description = "The app folder name to recursively copy from the install archive. e.g., Foo.app";
      };
      version = mkOption {
        default = archSpecs.${stdenv.hostPlatform.system}.version;
        description = "The version of the app.";
      };
      date = mkOption {
        default = archSpecs.${stdenv.hostPlatform.system}.date;
        description = "The build date (if applicable).";
      };
      revision = mkOption {
        default = archSpecs.${stdenv.hostPlatform.system}.revision;
        description = "The build number of the app (if applicable).";
      };
      url = mkOption {
        default = archSpecs.${stdenv.hostPlatform.system}.url;
        description = "The url or url template for the archive.";
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
        name = "free-ruler";
        description = "Horizontal and vertical rulers";
        sourceRoot = cfg.sourceRoot;
        version = cfg.version;
        src = pkgs.fetchurl {
          url = cfg.url;
          sha256 = cfg.sha256;
          name = "${(toHyphenedLower name)}-${arch}-${version}.zip";
        };
        appcast = "https://formulae.brew.sh/api/cask/free-ruler.json";
        homepage = "https://www.pascal.com/software/freeruler/";
      });
  };
}
