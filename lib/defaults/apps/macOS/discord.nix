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
      version = "0.0.268";
      revision = "";
      arch = "amd64";
      sha256 = "dfe12315b717ed06ac24d3eaacb700618e96cbb449ed63d2afadcdb70ad09c55";
    };
    aarch64-darwin = {
      version = "0.0.268";
      revision = "";
      arch = "arm64";
      sha256 = "dfe12315b717ed06ac24d3eaacb700618e96cbb449ed63d2afadcdb70ad09c55";
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
        default = "";
        description = "The build date (if applicable).";
      };
      revision = mkOption {
        default = archSpecs.${stdenv.hostPlatform.system}.revision;
        description = "The build number of the app (if applicable).";
      };
      sha256 = mkOption {
        default = archSpecs.${stdenv.hostPlatform.system}.sha256;
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
          name = "${(toHyphenedLower name)}-${arch}-${version}.dmg";
        };
        appcast = "https://formulae.brew.sh/api/cask/discord.json";
        homepage = "https://discord.com/";
      });
  };
}
