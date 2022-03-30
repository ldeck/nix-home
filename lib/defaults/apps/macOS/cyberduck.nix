{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.macOS.apps.cyberduck;
  arch = if stdenv.isDarwin stdenv.hostPlatform.darwinArch else stdenv.system;
  toHyphenedLower = str:
    (lib.strings.toLower (builtins.replaceStrings [" "] ["-"] str));
in {
  options = {
    macOS.apps.cyberduck = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      sourceRoot = mkOption {
        default = "Cyberduck.app";
        description = "The app folder name to recursively copy from the install archive. e.g., Foo.app";
      };
      version = mkOption {
        default = "8.3.0";
        description = "The version of the app.";
      };
      buildNumber = mkOption {
        default = "37309";
        description = "The build number of the app (if applicable).";
      };
      sha256 = mkOption {
        default = "da992c3d1082166d3f780c73cc0dd62fa3450a00c502df954f7e6c3886ef1b5e";
        description = "The sha256 for the app.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages =
      (pkgs.callPackage ./lib/app.nix rec {
        name = "Cyberduck";
        description = "Server and cloud storage browser";
        sourceRoot = cfg.sourceRoot;
        version = cfg.version;
        src = pkgs.fetchurl {
          url = "https://update.cyberduck.io/Cyberduck-${cfg.version}.${cfg.buildNumber}.zip";
          sha256 = cfg.sha256;
          name = "${(toHyphenedLower name)}-${arch}-${version}.zip";
        };
        appcast = "https://formulae.brew.sh/api/cask/cyberduck.json";
        homepage = "https://cyberduck.io/";
      });
  };
}
