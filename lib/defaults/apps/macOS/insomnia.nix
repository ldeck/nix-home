{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.macOS.apps.insomnia;
  stdenv = pkgs.stdenv;
  arch = if stdenv.isDarwin then stdenv.hostPlatform.darwinArch else stdenv.system;
  toHyphenedLower = str:
    (lib.strings.toLower (builtins.replaceStrings [" "] ["-"] str));

  archSpecs = {
    x86_64-darwin = {
      version = "2022.5.0";
      revision = "";
      arch = "amd64";
      sha256 = "a9eb73fc4f12523d31ea3af03b72eedb88f966b3e5ccaf25f494574acbc93563";
    };
    aarch64-darwin = {
      version = "2022.5.0";
      revision = "";
      arch = "arm64";
      sha256 = "a9eb73fc4f12523d31ea3af03b72eedb88f966b3e5ccaf25f494574acbc93563";
    };
  };

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
