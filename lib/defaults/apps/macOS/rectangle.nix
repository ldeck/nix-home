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
      version = "0.88";
      revision = "";
      date = "";
      arch = "amd64";
      url = "https://github.com/rxhanson/Rectangle/releases/download/v${cfg.version}/Rectangle${cfg.version}.dmg";
      sha256 = "632be7bbc9fe980fb4097e716ed3acf598c6f7d7b14d3d688f78868b10e8b547";
      imagetype = "dmg";
    };
    aarch64-darwin = {
      version = "0.88";
      revision = "";
      date = "";
      arch = "arm64";
      url = "https://github.com/rxhanson/Rectangle/releases/download/v${cfg.version}/Rectangle${cfg.version}.dmg";
      sha256 = "632be7bbc9fe980fb4097e716ed3acf598c6f7d7b14d3d688f78868b10e8b547";
      imagetype = "dmg";
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
      imagetype = mkOption {
        default = archSpecs.${stdenv.hostPlatform.system}.imagetype;
        description = "The image type being downloaded.";
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
          name = "${(toHyphenedLower name)}-${arch}-${version}.${cfg.imagetype}";
        };
        appcast = "https://formulae.brew.sh/api/cask/rectangle.json";
        homepage = "https://rectangleapp.com/";
      });
  };
}
