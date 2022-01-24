{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.macOS.apps.rectangle;
in {
  options = {
    macOS.apps.rectangle = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      version = mkOption {
        default = "0.50";
        description = "The version of the app.";
      };
      sha256 = mkOption {
        default = "b1323721795da2401736a60b300472d0d6c6727f5072992d27e794315556467c";
        description = "The sha256 for the app.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages =
      (pkgs.callPackage ./lib/app.nix rec {
        name = "Rectangle";
        description = "Move and resize windows using keyboard shortcuts or snap areas";
        sourceRoot = "${name}.app";
        version = cfg.version;
        src = pkgs.fetchurl {
          url = "https://github.com/rxhanson/Rectangle/releases/download/v${cfg.version}/Rectangle${cfg.version}.dmg";
          sha256 = cfg.sha256;
          name = "${name}-${version}.dmg";
        };
        appcast = "https://formulae.brew.sh/api/cask/rectangle.json";
        homepage = "https://rectangleapp.com/";
      });
  };
}
