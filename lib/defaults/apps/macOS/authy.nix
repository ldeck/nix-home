{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.macOS.apps.authy;
  stdenv = pkgs.stdenv;
  arch = if stdenv.isDarwin then stdenv.hostPlatform.darwinArch else stdenv.system;
  toHyphenedLower = str:
    (lib.strings.toLower (builtins.replaceStrings [" "] ["-"] str));
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
        default = "2.1.0";
        description = "The version of the app.";
      };
      sha256 = mkOption {
        default = "988f53a6d18fce648f5c6f6055cb7db644f186667a3d7fce6571f288f94e70e6";
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
