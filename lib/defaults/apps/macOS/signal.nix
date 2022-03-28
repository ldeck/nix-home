{ config, lib, pkgs, ... }:
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
        default = "5.36.0";
        description = "The version of the app.";
      };
      sha256 = mkOption {
        default = "24563d6a599f160d97a9c9c6f3d129707aec71b5f1ba619ac3a5cf77dec17170";
        description = "The sha256 for the app.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages =
      (pkgs.callPackage ./lib/app.nix rec {
        name = "Signal";
        description = "Instant messaging application focusing on security";
        sourceRoot = "${name}.app";
        version = cfg.version;
        src = pkgs.fetchurl {
          url = "https://updates.signal.org/desktop/signal-desktop-mac-x64-${cfg.version}.dmg";
          sha256 = cfg.sha256;
          name = "${name}-${version}.dmg";
        };
        appcast = "https://formulae.brew.sh/api/cask/signal.json";
        homepage = "https://signal.org/";
      });
  };
}
