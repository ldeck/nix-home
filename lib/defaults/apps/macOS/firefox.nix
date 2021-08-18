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
        default = "89.0";
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
