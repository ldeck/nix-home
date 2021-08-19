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
        default = "2021.2";
        description = "The version of the app";
      };
      sha256 = mkOption {
        default = "c23ee9f68abbd503e5019c745cc5bf2a308f81e8c2bbd210ccfafbc1124c1e59";
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
        arch = if stdenv.isAarch64 then "-aarch64" else "";
        src = pkgs.fetchurl {
          url = "https://download.jetbrains.com/idea/ideaIU-${version}${arch}.dmg";
          sha256 = cfg.sha256;
        };
        description = "The most intelligent JVM IDE";
        homepage = https://www.jetbrains.com/idea/;
        appcast = https://www.jetbrains.com/idea/download/other.html;
      });
  };
}
