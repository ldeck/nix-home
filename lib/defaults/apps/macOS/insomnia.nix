{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.macOS.apps.insomnia;
  stdenv = pkgs.stdenv;
  arch = if stdenv.isDarwin then stdenv.hostPlatform.darwinArch else stdenv.system;
  toHyphenedLower = str:
    (lib.strings.toLower (builtins.replaceStrings [" "] ["-"] str));
in {
  options = {
    macOS.apps.insomnia = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      sourceRoot = mkOption {
        default = "Insomnia.app";
        description = "The app folder name to recursively copy from the install archive. e.g., Foo.app";
      };
      version = mkOption {
        default = "2022.3.0";
        description = "The version of the app.";
      };
      sha256 = mkOption {
        default = "6d718ab33e97cca636d6edfbf83daa545741bf5b66023b16b2b27b8703ab0dca";
        description = "The sha256 for the app.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages =
      (pkgs.callPackage ./lib/app.nix rec {
        name = "Insomnia";
        description = "HTTP and GraphQL Client";
        sourceRoot = cfg.sourceRoot;
        version = cfg.version;
        src = pkgs.fetchurl {
          url = "https://github.com/Kong/insomnia/releases/download/core%40${cfg.version}/Insomnia.Core-${cfg.version}.dmg";
          sha256 = cfg.sha256;
          name = "${(toHyphenedLower name)}-${arch}-${version}.dmg";
        };
        appcast = "https://formulae.brew.sh/api/cask/insomnia.json";
        homepage = "https://insomnia.rest/";
      });
  };
}
