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
      version = mkOption {
        default = "8.2.1";
        description = "The version of the app.";
      };
      buildNumber = mkOption {
        default = "36773";
        description = "The build number of the app (if applicable).";
      };
      sha256 = mkOption {
        default = "052125fa4acfb4dc42b6e6849d9307d26ac543d723c088f3a1f86ffdb15fe8c9";
        description = "The sha256 for the app.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages =
      (pkgs.callPackage ./lib/app.nix rec {
        name = "Cyberduck";
        description = "Server and cloud storage browser";
        sourceRoot = "${name}.app";
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
