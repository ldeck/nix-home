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
        default = "0z86q1hlwmhfwrddhapwiy8qrn3v03d7nbsnzhnkr3fc9vz58ga3";
        description = "The sha256 for the defined version";
      };
    };
  };

  config = {
    home.packages = lib.optionals cfg.enable
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
