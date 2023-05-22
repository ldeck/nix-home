{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.macOS.apps.rectangle;
  stdenv = pkgs.stdenv;
  arch = if stdenv.isDarwin then stdenv.hostPlatform.darwinArch else stdenv.system;
  toHyphenedLower = str:
    (lib.strings.toLower (builtins.replaceStrings [" "] ["-"] str));

  archSpecs = {
    x86_64-darwin = {
      version = "0.68";
      revision = "";
      date = "";
      arch = "amd64";
      url = "https://github.com/rxhanson/Rectangle/releases/download/v${cfg.version}/Rectangle${cfg.version}.dmg";
      sha256 = "375cd2326468eaec7f6f5e8ae0e83af00e5b7e1b765968bb4b8d18cacdd09136";
    };
    aarch64-darwin = {
      version = "0.68";
      revision = "";
      date = "";
      arch = "arm64";
      url = "https://github.com/rxhanson/Rectangle/releases/download/v${cfg.version}/Rectangle${cfg.version}.dmg";
      sha256 = "375cd2326468eaec7f6f5e8ae0e83af00e5b7e1b765968bb4b8d18cacdd09136";
    };
  };

in {
  options = {
    macOS.apps.rectangle = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      sourceRoot = mkOption {
        default = "Rectangle.app";
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
        name = "Rectangle";
        description = "Move and resize windows using keyboard shortcuts or snap areas";
        sourceRoot = cfg.sourceRoot;
        version = cfg.version;
        src = pkgs.fetchurl {
          url = cfg.url;
          sha256 = cfg.sha256;
          name = "${(toHyphenedLower name)}-${arch}-${version}.dmg";
        };
        appcast = "https://formulae.brew.sh/api/cask/rectangle.json";
        homepage = "https://rectangleapp.com/";
      });
  };
}
