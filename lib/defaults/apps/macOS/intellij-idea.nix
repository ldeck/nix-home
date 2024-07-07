{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.macOS.apps.intellij-idea;
  stdenv = pkgs.stdenv;
  arch = if stdenv.isDarwin then stdenv.hostPlatform.darwinArch else stdenv.system;
  toHyphenedLower = str:
    (lib.strings.toLower (builtins.replaceStrings [" "] ["-"] str));

  archSpecs = {
    x86_64-darwin = {
      version = "2024.1.4";
      revision = "241.18034.62";
      date = "";
      arch = "amd64";
      url = "https://download.jetbrains.com/idea/ideaIU-${cfg.version}.dmg";
      sha256 = "30396377e163ba7f8d5c4ef112e9c8abb064897dd337f059357feecaa6c53b6e";
      imagetype = "dmg";
    };
    aarch64-darwin = {
      version = "2024.1.4";
      revision = "241.18034.62";
      date = "";
      arch = "arm64";
      url = "https://download.jetbrains.com/idea/ideaIU-${cfg.version}-aarch64.dmg";
      sha256 = "0d6dd0ebc97a61920721fb6c9663a905df1edea976f62b32bdf8ff879c02c7d0";
      imagetype = "dmg";
    };
  };

in {
  options = {
    macOS.apps.intellij-idea = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      sourceRoot = mkOption {
        default = "IntelliJ IDEA.app";
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
        name = "IntelliJ IDEA";
        description = "Java IDE by JetBrains";
        sourceRoot = cfg.sourceRoot;
        version = cfg.version;
        src = pkgs.fetchurl {
          url = cfg.url;
          sha256 = cfg.sha256;
          name = "${(toHyphenedLower name)}-${arch}-${version}.${cfg.imagetype}";
        };
        appcast = "https://formulae.brew.sh/api/cask/intellij-idea.json";
        homepage = "https://www.jetbrains.com/idea/";
      });
  };
}
