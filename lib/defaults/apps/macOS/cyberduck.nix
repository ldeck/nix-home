{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.macOS.apps.cyberduck;
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
        default = "8.2.3";
        description = "The version of the app.";
      };
      buildNumber = mkOption {
        default = "36880";
        description = "The build number of the app (if applicable).";
      };
      sha256 = mkOption {
        default = "edac85691a21fee1c1d10fc72dfc7ca91230273bc31a37d0a7b8b1e8afa30d80";
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
          name = "${name}-${version}.zip";
        };
        appcast = "https://formulae.brew.sh/api/cask/cyberduck.json";
        homepage = "https://cyberduck.io/";
      });
  };
}
