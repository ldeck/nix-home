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
        default = "0.0.264";
        description = "The version of the app";
      };
      sha256 = mkOption {
        default = "f7e8e401d1d1526eef3176cd75e38807cf73e25c4fe76b42d65443ec56ed74cb";
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
