{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.macOS.apps.discord;
  stdenv = pkgs.stdenv;
  arch = if stdenv.isDarwin then stdenv.hostPlatform.darwinArch else stdenv.system;
  toHyphenedLower = str:
    (lib.strings.toLower (builtins.replaceStrings [" "] ["-"] str));

  archSpecs = {
    x86_64-darwin = {
      version = "0.0.343";
      revision = "";
      date = "";
      arch = "amd64";
      url = "https://dl.discordapp.net/apps/osx/${cfg.version}/Discord.dmg";
      sha256 = "f3e630e9675a06fbde88ffc799995494246c9c023824c59f5e3bd61c685a8a76";
      imagetype = "dmg";
    };
    aarch64-darwin = {
      version = "0.0.343";
      revision = "";
      date = "";
      arch = "arm64";
      url = "https://dl.discordapp.net/apps/osx/${cfg.version}/Discord.dmg";
      sha256 = "f3e630e9675a06fbde88ffc799995494246c9c023824c59f5e3bd61c685a8a76";
      imagetype = "dmg";
    };
  };

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
        default = archSpecs.${stdenv.hostPlatform.system}.version;
        description = "The version of the app.";
      };
      date = mkOption {
        default = archSpecs.${stdenv.hostPlatform.system}.date;
        description = "The build date (if applicable).";
      };
      revision = mkOption {
        default = archSpecs.${stdenv.hostPlatform.system}.revision;
        description = "The build number of the app (if applicable).";
      };
      url = mkOption {
        default = archSpecs.${stdenv.hostPlatform.system}.url;
        description = "The url or url template for the archive.";
      };
      sha256 = mkOption {
        default = archSpecs.${stdenv.hostPlatform.system}.sha256;
        description = "The sha256 for the app.";
      };
      imagetype = mkOption {
        default = archSpecs.${stdenv.hostPlatform.system}.imagetype;
        description = "The image type being downloaded.";
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
          url = cfg.url;
          sha256 = cfg.sha256;
          name = "${(toHyphenedLower name)}-${arch}-${version}.${cfg.imagetype}";
        };
        appcast = "https://formulae.brew.sh/api/cask/discord.json";
        homepage = "https://discord.com/";
      });
  };
}
