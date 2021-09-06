{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.macOS.apps.firefox;
in {
  options = {
    macOS.apps.firefox = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      version = mkOption {
        default = "91.0.2";
        description = "The version of the app";
      };
      sha256 = mkOption {
        default = "0c5b7k4q7k3q9lk0k22h6csk3bwqxkkfya6rskb5k9knn7qzyis1";
        description = "The sha256 for the defined version";
      };
    };
  };

  config = {
    home.packages = lib.optionals cfg.enable
      (pkgs.callPackage ./lib/app.nix rec {
        name = "Firefox";
        sourceRoot = "Firefox.app";
        version = cfg.version;
        src = pkgs.fetchurl {
          url = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/${version}/mac/en-US/Firefox+${version}.dmg";
          sha256 = cfg.sha256;
          name = "Firefox-${version}.dmg";
        };
        description = "The Firefox web browser";
        homepage = https://www.mozilla.org/en-US/firefox/;
        appcast = https://www.mozilla.org/en-US/firefox/releases/;
      });
  };
}
