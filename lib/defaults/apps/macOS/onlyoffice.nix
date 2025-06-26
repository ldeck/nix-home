{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.macOS.apps.onlyoffice;
  stdenv = pkgs.stdenv;
  arch = if stdenv.isDarwin then stdenv.hostPlatform.darwinArch else stdenv.system;
  toHyphenedLower = str:
    (lib.strings.toLower (builtins.replaceStrings [" "] ["-"] str));

  archSpecs = {
    x86_64-darwin = {
      version = "9.0.0";
      revision = "";
      date = "";
      arch = "amd64";
      url = "https://download.onlyoffice.com/install/desktop/editors/mac/arm/updates/ONLYOFFICE-arm-${cfg.version}.zip";
      sha256 = "db1f3a21e766c3c1fae4a2c27205f2988aa03c7a5c959b6a013be6ad763c9ec7";
      imagetype = "zip";
    };
    aarch64-darwin = {
      version = "9.0.0";
      revision = "";
      date = "";
      arch = "arm64";
      url = "https://download.onlyoffice.com/install/desktop/editors/mac/arm/updates/ONLYOFFICE-arm-${cfg.version}.zip";
      sha256 = "db1f3a21e766c3c1fae4a2c27205f2988aa03c7a5c959b6a013be6ad763c9ec7";
      imagetype = "zip";
    };
  };

in {
  options = {
    macOS.apps.onlyoffice = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      sourceRoot = mkOption {
        default = "ONLYOFFICE.app";
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
        name = "ONLYOFFICE";
        description = "Document editor";
        sourceRoot = cfg.sourceRoot;
        version = cfg.version;
        src = pkgs.fetchurl {
          url = cfg.url;
          sha256 = cfg.sha256;
          name = "${(toHyphenedLower name)}-${arch}-${version}.${cfg.imagetype}";
        };
        appcast = "https://formulae.brew.sh/api/cask/onlyoffice.json";
        homepage = "https://www.onlyoffice.com/";
      });
  };
}
