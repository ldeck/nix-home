{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.macOS.apps.firefox;
  stdenv = pkgs.stdenv;
  arch = if stdenv.isDarwin then stdenv.hostPlatform.darwinArch else stdenv.system;
  toHyphenedLower = str:
    (lib.strings.toLower (builtins.replaceStrings [" "] ["-"] str));

  archSpecs = {
    x86_64-darwin = {
      version = "113.0.1";
      revision = "";
      date = "";
      arch = "amd64";
      url = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/${cfg.version}/mac/en-US/Firefox%20${cfg.version}.dmg";
      sha256 = "9556a573435887378246e9df6ca27f719f7690f9a89155a4f2b5607c4b8240b9";
    };
    aarch64-darwin = {
      version = "113.0.1";
      revision = "";
      date = "";
      arch = "arm64";
      url = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/${cfg.version}/mac/en-US/Firefox%20${cfg.version}.dmg";
      sha256 = "9556a573435887378246e9df6ca27f719f7690f9a89155a4f2b5607c4b8240b9";
    };
  };

in {
  options = {
    macOS.apps.firefox = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      sourceRoot = mkOption {
        default = "Firefox.app";
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
        name = "Firefox";
        description = "Web browser";
        sourceRoot = cfg.sourceRoot;
        version = cfg.version;
        src = pkgs.fetchurl {
          url = cfg.url;
          sha256 = cfg.sha256;
          name = "${(toHyphenedLower name)}-${arch}-${version}.dmg";
        };
        appcast = "https://formulae.brew.sh/api/cask/firefox.json";
        homepage = "https://www.mozilla.org/firefox/";
      });
  };
}
