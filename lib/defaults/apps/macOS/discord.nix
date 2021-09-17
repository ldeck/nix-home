{
  config,
  lib,
  pkgs,
  ...
}:

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
        default = "0.0.263";
        description = "The version of the app";
      };
      sha256 = mkOption {
        default = "f6bed5976d1ee223b42986b185626fbc758d5f918aff27d3d7b0c2212406cba9";
        description = "The sha256 for the defined version";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      (pkgs.callPackage ./lib/app.nix rec {
        name = "Discord";
        sourceRoot = "${name}.app";
        version = cfg.version;
        src = pkgs.fetchurl {
          url = "https://dl.discordapp.net/apps/osx/${version}/Discord.dmg";
          sha256 = cfg.sha256;
        };
        description = ''
        Your place to talk. Whether you’re part of a school club, gaming group, worldwide art community, or just a handful of friends that want to spend time together, Discord makes it easy to talk every day and hang out more often.
      '';
      appcast = https://discord.com/api/stable/updates?platform=osx;
      homepage = https://discord.com;
      });
  };
}
