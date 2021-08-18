{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.macOS.apps.chromium;
in {
  options = {
    macOS.apps.chromium = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      version = mkOption {
        default = "841414";
        description = "The version of this app";
      };
      sha256 = mkOption {
        default = "11bn7finc76kamdrh61icvg35wfnpch3rpxpa0gigzwar3gfn7q2";
        description = "The sha256 for the defined version";
      };
    };
  };

  config = {
    home.packages = lib.optionals cfg.enable
      (pkgs.callPackage ./lib/app.nix rec {
        name = "Chromium";
        sourceRoot = "chrome-mac/${name}.app";
        version = cfg.version;
        src = pkgs.fetchurl {
          url = "https://commondatastorage.googleapis.com/chromium-browser-snapshots/Mac/${version}/chrome-mac.zip";
          sha256 = cfg.sha256;
        };
        description = "Chromium is an open-source browser project that aims to build a safer, faster, and more stable way for all Internet users to experience the web.";
      homepage = "https://chromium.org/Home";
      appcast = "https://chromiumdash.appspot.com/releases?platform=Mac";
      });
  };
}
