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
      version = "2023.3.0";
      revision = "";
      date = "";
      arch = "amd64";
      url = "https://github.com/Kong/insomnia/releases/download/core%40${cfg.version}/Insomnia.Core-${cfg.version}.dmg";
      sha256 = "e1d4e524fc8779b73e86323f66e1b5b838d0f9c1bc542e6c718db83223cc315f";
    };
    aarch64-darwin = {
      version = "2023.3.0";
      revision = "";
      date = "";
      arch = "arm64";
      url = "https://github.com/Kong/insomnia/releases/download/core%40${cfg.version}/Insomnia.Core-${cfg.version}.dmg";
      sha256 = "e1d4e524fc8779b73e86323f66e1b5b838d0f9c1bc542e6c718db83223cc315f";
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
          url = cfg.url;
          sha256 = cfg.sha256;
          name = "${(toHyphenedLower name)}-${arch}-${version}.dmg";
        };
        appcast = "https://formulae.brew.sh/api/cask/insomnia.json";
        homepage = "https://insomnia.rest/";
      });
  };
}
