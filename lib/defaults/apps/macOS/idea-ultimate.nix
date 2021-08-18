{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.macOS.apps.idea-ultimate;
in {
  options = {
    macOS.apps.idea-ultimate = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      version = mkOption {
        default = "2021.1.3";
        description = "The version of the app";
      };
      sha256 = mkOption {
        default = "1m2yrydlpxw6cvr35yvx1q5n2snvbh8gjampq39vciawmq95yvqm";
        description = "The sha256 for the defined version";
      };
    };
  };

  config = {
    home.packages = lib.optionals cfg.enable
      (pkgs.callPackage ./lib/app.nix rec {
        name = "IntelliJIDEA";
        sourceRoot = "IntelliJ IDEA.app";
        version = cfg.version;
        src = pkgs.fetchurl {
          url = "https://download.jetbrains.com/idea/ideaIU-${version}.dmg";
          sha256 = cfg.sha256;
        };
        description = "The most intelligent JVM IDE";
        homepage = https://www.jetbrains.com/idea/;
        appcast = https://www.jetbrains.com/idea/download/other.html;
      });
  };
}
