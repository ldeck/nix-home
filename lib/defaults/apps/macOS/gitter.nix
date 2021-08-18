{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.macOS.apps.gitter;
in {
  options = {
    macOS.apps.gitter = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      version = mkOption {
        default = "1.177";
        description = "The version of the app";
      };
      sha256 = mkOption {
        default = "0ca1c0d52c342548afbea8d3501282a4ccf494058aa2e23af27e09198a7a30a4";
        description = "The sha256 for the defined version";
      };
    };
  };

  config = {
    home.packages = lib.optionals cfg.enable
      (pkgs.callPackage ./lib/app.nix rec {
        name = "Gitter";
        sourceRoot = "Gitter.app";
        version = cfg.version;
        src = pkgs.fetchurl {
          url = "https://update.gitter.im/osx/Gitter-${version}.dmg";
          sha256 = cfg.sha256;
        };
        description = "Gitter is a chat and networking platform that helps to manage, grow and connect communities through messaging, content and discovery.";
        homepage = "https://gitter.im";
        appcast = "https://update.gitter.im/osx/appcast.xml";
      });
  };
}
