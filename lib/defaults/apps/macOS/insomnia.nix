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
        default = "2021.5.2";
        description = "The version of the app";
      };
      sha256 = mkOption {
        default = "11dq74q7v7043ggiy3lqhgnjpqs3bx8sgm5zvww3nybj6zjpmqii";
        description = "The sha256 for the defined version";
      };
    };
  };

  config = {
    home.packages = lib.optionals cfg.enable
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
