{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.macOS.apps.discord;
in {
  options = {
    macOS.apps.discord = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      version = mkOption {
        default = "0.0.265";
        description = "The version of the app.";
      };
      sha256 = mkOption {
        default = "2f2c7290a5b2723325ecbebf3c92496e6e8b7f0ef5f6b8bc12784c5a3e3ac93b";
        description = "The sha256 for the app.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages =
      (pkgs.callPackage ./lib/app.nix rec {
        name = "Discord";
        description = "Voice and text chat software";
        sourceRoot = "${name}.app";
        version = cfg.version;
        src = pkgs.fetchurl {
          url = "https://dl.discordapp.net/apps/osx/${cfg.version}/Discord.dmg";
          sha256 = cfg.sha256;
          name = "${name}-${version}.dmg";
        };
        appcast = "https://formulae.brew.sh/api/cask/discord.json";
        homepage = "https://discord.com/";
      });
  };
}
