{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.macOS.apps.netnewswire;
  stdenv = pkgs.stdenv;
  arch = if stdenv.isDarwin then stdenv.hostPlatform.darwinArch else stdenv.system;
  toHyphenedLower = str:
    (lib.strings.toLower (builtins.replaceStrings [" "] ["-"] str));

  archSpecs = {
    x86_64-darwin = {
      version = "6.1.1";
      revision = "";
      date = "";
      arch = "amd64";
      url = "https://github.com/Ranchero-Software/NetNewsWire/releases/download/mac-${cfg.version}/NetNewsWire${cfg.version}.zip";
      sha256 = "ad8441a109d0581e1b6f5ab353331e4ece94e534ca18a2a7bed2b1f06260453e";
    };
    aarch64-darwin = {
      version = "6.1.1";
      revision = "";
      date = "";
      arch = "arm64";
      url = "https://github.com/Ranchero-Software/NetNewsWire/releases/download/mac-${cfg.version}/NetNewsWire${cfg.version}.zip";
      sha256 = "ad8441a109d0581e1b6f5ab353331e4ece94e534ca18a2a7bed2b1f06260453e";
    };
  };

in {
  options = {
    macOS.apps.netnewswire = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      sourceRoot = mkOption {
        default = "NetNewsWire.app";
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
        name = "netnewswire";
        description = "Free and open-source RSS reader";
        sourceRoot = cfg.sourceRoot;
        version = cfg.version;
        src = pkgs.fetchurl {
          url = cfg.url;
          sha256 = cfg.sha256;
          name = "${(toHyphenedLower name)}-${arch}-${version}.zip";
        };
        appcast = "https://formulae.brew.sh/api/cask/netnewswire.json";
        homepage = "https://netnewswire.com/";
      });
  };
}
