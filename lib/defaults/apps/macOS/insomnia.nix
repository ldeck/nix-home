{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.macOS.apps.insomnia;
in {
  options = {
    macOS.apps.insomnia = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      version = mkOption {
        default = "2021.7.2";
        description = "The version of the app.";
      };
      sha256 = mkOption {
        default = "6a50eebf632ac6416569e4addbcccdd05dcccdd1023e0008f8971b58d3f6d647";
        description = "The sha256 for the app.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages =
      (pkgs.callPackage ./lib/app.nix rec {
        name = "Insomnia";
        description = "HTTP and GraphQL Client";
        sourceRoot = "${name}.app";
        version = cfg.version;
        src = pkgs.fetchurl {
          url = "https://github.com/Kong/insomnia/releases/download/core%40${cfg.version}/Insomnia.Core-${cfg.version}.dmg";
          sha256 = cfg.sha256;
          name = "${name}-${version}.dmg";
        };
        appcast = "https://formulae.brew.sh/api/cask/insomnia.json";
        homepage = "https://insomnia.rest/";
      });
  };
}
