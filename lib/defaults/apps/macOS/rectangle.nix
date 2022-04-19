{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.macOS.apps.rectangle;
  stdenv = pkgs.stdenv;
  arch = if stdenv.isDarwin then stdenv.hostPlatform.darwinArch else stdenv.system;
  toHyphenedLower = str:
    (lib.strings.toLower (builtins.replaceStrings [" "] ["-"] str));
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
        default = "0.53";
        description = "The version of the app.";
      };
      sha256 = mkOption {
        default = "759e614c00668cdb0ae00acccbd1dbe7484291bd97ec5722c74520c537ba4273";
        description = "The sha256 for the app.";
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
          url = "https://github.com/rxhanson/Rectangle/releases/download/v${cfg.version}/Rectangle${cfg.version}.dmg";
          sha256 = cfg.sha256;
          name = "${(toHyphenedLower name)}-${arch}-${version}.dmg";
        };
        appcast = "https://formulae.brew.sh/api/cask/rectangle.json";
        homepage = "https://rectangleapp.com/";
      });
  };
}
