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
      version = "6.2.1";
      revision = "";
      date = "";
      arch = "amd64";
      url = "https://github.com/Ranchero-Software/NetNewsWire/releases/download/mac-${cfg.version}/NetNewsWire${cfg.version}.zip";
      sha256 = "16dd22ef68104ac4f885c61c0a6a944bc2cdce6c5b95cb8ab29ee1c894c86729";
      imagetype = "zip";
    };
    aarch64-darwin = {
      version = "6.2.1";
      revision = "";
      date = "";
      arch = "arm64";
      url = "https://github.com/Ranchero-Software/NetNewsWire/releases/download/mac-${cfg.version}/NetNewsWire${cfg.version}.zip";
      sha256 = "16dd22ef68104ac4f885c61c0a6a944bc2cdce6c5b95cb8ab29ee1c894c86729";
      imagetype = "zip";
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
      imagetype = mkOption {
        default = archSpecs.${stdenv.hostPlatform.system}.imagetype;
        description = "The image type being downloaded.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages =
      (pkgs.callPackage ./lib/app.nix rec {
        name = "NetNewsWire";
        description = "Free and open-source RSS reader";
        sourceRoot = cfg.sourceRoot;
        version = cfg.version;
        src = pkgs.fetchurl {
          url = cfg.url;
          sha256 = cfg.sha256;
          name = "${(toHyphenedLower name)}-${arch}-${version}.${cfg.imagetype}";
        };
        appcast = "https://formulae.brew.sh/api/cask/netnewswire.json";
        homepage = "https://netnewswire.com/";
      });
  };
}
