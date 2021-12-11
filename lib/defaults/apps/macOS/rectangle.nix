{
  config,
  lib,
  pkgs,
  ...
}:

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
        default = "0.49";
        description = "The version of the app";
      };
      sha256 = mkOption {
        default = "60699a4f1700de0edb30668a2342840b8d62257ced73e7d9e9812eb62f009389";
        description = "The sha256 for the defined version";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      (pkgs.callPackage ./lib/app.nix rec {
        name = "Rectangle";
        sourceRoot = "Rectangle.app";
        version = cfg.version;
        src = pkgs.fetchurl {
          url = "https://github.com/rxhanson/Rectangle/releases/download/v${version}/Rectangle${version}.dmg";
          sha256 = cfg.sha256;
        };
        description = "Move and resize windows in macOS using keyboard shortcuts or snap areas.";
        homepage = "https://rectangleapp.com";
        appcast = "https://github.com/rxhanson/Rectangle/releases";
      });
  };
}
