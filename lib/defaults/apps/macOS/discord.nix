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
      sourceRoot = mkOption {
        default = "Discord.app";
        description = "The app folder name to recursively copy from the install archive. e.g., Foo.app";
      };
      version = mkOption {
        default = "0.0.266";
        description = "The version of the app.";
      };
      sha256 = mkOption {
        default = "ca304913ad6a66d8f17af0f8486880f88988fb4d947b8d858421531715c529c4";
        description = "The sha256 for the app.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages =
      (pkgs.callPackage ./lib/app.nix rec {
        name = "Discord";
        description = "Voice and text chat software";
        sourceRoot = cfg.sourceRoot;
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
