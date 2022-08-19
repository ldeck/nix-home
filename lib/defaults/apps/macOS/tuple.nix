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
      version = "0.98.2";
      revision = "99364aa15";
      arch = "amd64";
      sha256 = "aadd3a9dd9a9ee3034ce33f96894d83448b1505913e10bdad60b56453298e774";
    };
    aarch64-darwin = {
      version = "0.98.2";
      revision = "99364aa15";
      arch = "arm64";
      sha256 = "aadd3a9dd9a9ee3034ce33f96894d83448b1505913e10bdad60b56453298e774";
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
        default = "2022-07-27";
        description = "The build date (if applicable).";
      };
      revision = mkOption {
        default = archSpecs.${stdenv.hostPlatform.system}.revision;
        description = "The build number of the app (if applicable).";
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
        name = "Tuple";
        description = "Remote pair programming app";
        sourceRoot = cfg.sourceRoot;
        version = cfg.version;
        src = pkgs.fetchurl {
          url = "https://d32ifkf9k9ezcg.cloudfront.net/production/sparkle/tuple-${cfg.version}-${cfg.buildDate}-${cfg.revision}.zip";
          sha256 = cfg.sha256;
          name = "${(toHyphenedLower name)}-${arch}-${version}.zip";
        };
        appcast = "https://formulae.brew.sh/api/cask/tuple.json";
        homepage = "https://tuple.app/";
      });
  };
}
