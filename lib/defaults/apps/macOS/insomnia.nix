{
  config,
  lib,
  pkgs,
  ...
}:

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
        description = "The version of the app";
      };
      sha256 = mkOption {
        default = "6a50eebf632ac6416569e4addbcccdd05dcccdd1023e0008f8971b58d3f6d647";
        description = "The sha256 for the defined version";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      (pkgs.callPackage ./lib/app.nix rec {
        name = "Insomnia";
        sourceRoot = "Insomnia.app";
        version = cfg.version;
        src = pkgs.fetchurl {
          url = "https://github.com/Kong/insomnia/releases/download/core%40${version}/Insomnia.Core-${version}.dmg";
          sha256 = cfg.sha256;
        };
        description = "Cross-platform HTTP and GraphQL Client";
        homepage = https://insomnia.rest;
        appcast = "https://api.insomnia.rest/changelog.json?app=com.insomnia.app";
      });
  };
}
