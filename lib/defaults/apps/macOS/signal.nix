{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.macOS.apps.signal;
in {
  options = {
    macOS.apps.signal = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      version = mkOption {
        default = "5.4.0";
        description = "The version of the app";
      };
      sha256 = mkOption {
        default = "0rkbg67kajhykdsx799ljphbz00fak9dyyp4sxl12sdv77ajzc8j";
        description = "The sha256 for the defined version";
      };
    };
  };

  config = {
    home.packages = lib.optionals cfg.enable
      (pkgs.callPackage ./lib/app.nix rec {
        name = "Signal";
        sourceRoot = "Signal.app";
        version = cfg.version;
        src = pkgs.fetchurl {
          url = "https://updates.signal.org/desktop/signal-desktop-mac-${version}.dmg";
          sha256 = cfg.sha256;
        };
        description = "Cross-platform instant messaging application focusing on security";
        homepage = "https://signal.org/";
        appcast = "https://github.com/signalapp/Signal-Desktop/releases.atom";
      });
  };
}
