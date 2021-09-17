{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.macOS.apps.freeruler;
in {
  options = {
    macOS.apps.freeruler = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      version = mkOption {
        default = "2.0.5";
        description = "The version of the app";
      };
      sha256 = mkOption {
        default = "0ka4cvx58102hqn7mnxp9hphrqka9m4bax2z9azqviag58jvjck3";
        description = "The sha256 for the defined version";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      (pkgs.callPackage ./lib/app.nix rec {
        name = "FreeRuler";
        sourceRoot = "Free Ruler.app";
        version = cfg.version;
        src = pkgs.fetchurl {
          url = "https://github.com/pascalpp/FreeRuler/releases/download/v${version}/free-ruler-${version}.zip";
          sha256 = cfg.sha256;
        };
        description = "A ruler application for macOS";
        homepage = "http://www.pascal.com/software/freeruler/";
        appcast = "https://github.com/pascalpp/FreeRuler/releases";
      });
  };
}
