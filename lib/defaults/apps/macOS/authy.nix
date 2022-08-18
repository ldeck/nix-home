{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.macOS.apps.authy;
  stdenv = pkgs.stdenv;
  arch = if stdenv.isDarwin then stdenv.hostPlatform.darwinArch else stdenv.system;
  toHyphenedLower = str:
    (lib.strings.toLower (builtins.replaceStrings [" "] ["-"] str));

  archSpecs = {
    x86_64-darwin = {
      version = "2.2.1";
      revision = "";
      arch = "amd64";
      sha256 = "88663f7e83cec5a39c4336df9fb395b30447431c8902d0769211f1e31006d2db";
    };
    aarch64-darwin = {
      version = "2.2.1";
      revision = "";
      arch = "arm64";
      sha256 = "88663f7e83cec5a39c4336df9fb395b30447431c8902d0769211f1e31006d2db";
    };
  };

in {
  options = {
    macOS.apps.authy = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      sourceRoot = mkOption {
        default = "Authy Desktop.app";
        description = "The app folder name to recursively copy from the install archive. e.g., Foo.app";
      };
      version = mkOption {
        default = archSpecs.${stdenv.hostPlatform.system}.version;
        description = "The version of the app.";
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
        name = "Authy";
        description = "Two-factor authentication software";
        sourceRoot = cfg.sourceRoot;
        version = cfg.version;
        src = pkgs.fetchurl {
          url = "https://authy-electron-repository-production.s3.amazonaws.com/authy/stable/${cfg.version}/darwin/x64/Authy%20Desktop-${cfg.version}.dmg";
          sha256 = cfg.sha256;
          name = "${(toHyphenedLower name)}-${arch}-${version}.dmg";
        };
        appcast = "https://formulae.brew.sh/api/cask/authy.json";
        homepage = "https://authy.com/";
      });
  };
}
