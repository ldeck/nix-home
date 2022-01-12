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
        description = "Whether to enable this cask.";
      };
      version = mkOption {
        default = "96.0";
        description = "The version of the cask.";
      };
      sha256 = mkOption {
        default = "8c1b31765c245f23bbcdb84b8ffe0edb93f3dae7dfc561ec3f44c5378ad13019";
        description = "The sha256 for the cask.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages =
      (pkgs.callPackage ./lib/app.nix rec {
        name = "Firefox";
        description = "Web browser";
        sourceRoot = "${name}.app";
        version = cfg.version;
        versionedName = "${name}-${version}";
        src = pkgs.fetchurl {
          url = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/${cfg.version}/mac/en-US/Firefox%20${cfg.version}.dmg";
          sha256 = cfg.sha256;
          name = "${versionedName}.dmg";
        };
        appcast = "https://formulae.brew.sh/api/cask/firefox.json";
        homepage = "https://www.mozilla.org/firefox/";
      });
  };
}
