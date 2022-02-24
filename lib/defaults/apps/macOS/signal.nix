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
        default = "5.33.0";
        description = "The version of the app.";
      };
      sha256 = mkOption {
        default = "5e918f99bc156c25b779386c45990c15c7994d24c65c3be61d002a7b829bcd4d";
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
