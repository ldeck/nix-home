{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.macOS.apps.tuple;
  stdenv = pkgs.stdenv;
  arch = if stdenv.isDarwin then stdenv.hostPlatform.darwinArch else stdenv.system;
  toHyphenedLower = str:
    (lib.strings.toLower (builtins.replaceStrings [" "] ["-"] str));

  archSpecs = {
    x86_64-darwin = {
      version = "0.117.0";
      revision = "ff3de4cc3";
      date = "2024-06-13";
      arch = "amd64";
      url = "https://d32ifkf9k9ezcg.cloudfront.net/production/sparkle/tuple-${cfg.version}-${cfg.date}-${cfg.revision}.zip";
      sha256 = "55b719f6bc37d6d6ab52a9d1c80be9c1d4b4202e63e9f479291eefbd13cf2ece";
      imagetype = "zip";
    };
    aarch64-darwin = {
      version = "0.117.0";
      revision = "ff3de4cc3";
      date = "2024-06-13";
      arch = "arm64";
      url = "https://d32ifkf9k9ezcg.cloudfront.net/production/sparkle/tuple-${cfg.version}-${cfg.date}-${cfg.revision}.zip";
      sha256 = "55b719f6bc37d6d6ab52a9d1c80be9c1d4b4202e63e9f479291eefbd13cf2ece";
      imagetype = "zip";
    };
  };

in {
  options = {
    macOS.apps.tuple = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      sourceRoot = mkOption {
        default = "Tuple.app";
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
        name = "Tuple";
        description = "Remote pair programming app";
        sourceRoot = cfg.sourceRoot;
        version = cfg.version;
        src = pkgs.fetchurl {
          url = cfg.url;
          sha256 = cfg.sha256;
          name = "${(toHyphenedLower name)}-${arch}-${version}.${cfg.imagetype}";
        };
        appcast = "https://formulae.brew.sh/api/cask/tuple.json";
        homepage = "https://tuple.app/";
      });
  };
}
