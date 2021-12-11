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
        default = "5.25.1";
        description = "The version of the app";
      };
      sha256 = mkOption {
        default = "03351b238d118b853e2856e623c66b25f9f44da068befdae6e40b8f46d17b817";
        description = "The sha256 for the defined version";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages =
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
