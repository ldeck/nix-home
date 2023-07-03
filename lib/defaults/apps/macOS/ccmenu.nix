{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.macOS.apps.ccmenu;
  stdenv = pkgs.stdenv;
  arch = if stdenv.isDarwin then stdenv.hostPlatform.darwinArch else stdenv.system;
  toHyphenedLower = str:
    (lib.strings.toLower (builtins.replaceStrings [" "] ["-"] str));

  archSpecs = {
    x86_64-darwin = {
      version = "15.0";
      revision = "";
      date = "";
      arch = "amd64";
      url = "https://github.com/erikdoe/ccmenu/releases/download/v${cfg.version}/CCMenu.app.zip";
      sha256 = "4ee3c5f65828c30c5cbe147064396d387a175042601076adf12b6c1a99792c1d";
    };
    aarch64-darwin = {
      version = "15.0";
      revision = "";
      date = "";
      arch = "arm64";
      url = "https://github.com/erikdoe/ccmenu/releases/download/v${cfg.version}/CCMenu.app.zip";
      sha256 = "4ee3c5f65828c30c5cbe147064396d387a175042601076adf12b6c1a99792c1d";
    };
  };

in {
  options = {
    macOS.apps.ccmenu = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      sourceRoot = mkOption {
        default = "CCMenu.app";
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
        name = "CCMenu";
        description = "Application to monitor continuous integration servers";
        sourceRoot = cfg.sourceRoot;
        version = cfg.version;
        src = pkgs.fetchurl {
          url = cfg.url;
          sha256 = cfg.sha256;
          name = "${(toHyphenedLower name)}-${arch}-${version}.zip";
        };
        appcast = "https://formulae.brew.sh/api/cask/ccmenu.json";
        homepage = "https://ccmenu.org/";
      });
  };
}
