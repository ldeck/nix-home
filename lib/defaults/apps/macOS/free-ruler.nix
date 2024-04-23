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
      version = "2.0.8";
      revision = "";
      date = "";
      arch = "amd64";
      url = "https://github.com/pascalpp/FreeRuler/releases/download/v${cfg.version}/free-ruler-${cfg.version}.zip";
      sha256 = "697482a35fb13cb6f58678b443a57951180ad1046141f0e98d0fc8d1f1d67da6";
      imagetype = "zip";
    };
    aarch64-darwin = {
      version = "2.0.8";
      revision = "";
      date = "";
      arch = "arm64";
      url = "https://github.com/pascalpp/FreeRuler/releases/download/v${cfg.version}/free-ruler-${cfg.version}.zip";
      sha256 = "697482a35fb13cb6f58678b443a57951180ad1046141f0e98d0fc8d1f1d67da6";
      imagetype = "zip";
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
      imagetype = mkOption {
        default = archSpecs.${stdenv.hostPlatform.system}.imagetype;
        description = "The image type being downloaded.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages =
      (pkgs.callPackage ./lib/app.nix rec {
        name = "Free Ruler";
        description = "Horizontal and vertical rulers";
        sourceRoot = cfg.sourceRoot;
        version = cfg.version;
        src = pkgs.fetchurl {
          url = cfg.url;
          sha256 = cfg.sha256;
          name = "${(toHyphenedLower name)}-${arch}-${version}.${cfg.imagetype}";
        };
        appcast = "https://formulae.brew.sh/api/cask/free-ruler.json";
        homepage = "https://www.pascal.com/freeruler";
      });
  };
}
