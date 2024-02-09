{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.macOS.apps.docker;
  stdenv = pkgs.stdenv;
  arch = if stdenv.isDarwin then stdenv.hostPlatform.darwinArch else stdenv.system;
  toHyphenedLower = str:
    (lib.strings.toLower (builtins.replaceStrings [" "] ["-"] str));

  archSpecs = {
    x86_64-darwin = {
      version = "4.27.1";
      revision = "136059";
      date = "";
      arch = "amd64";
      url = "https://desktop.docker.com/mac/main/amd64/${cfg.revision}/Docker.dmg";
      sha256 = "7e2bb9403904078e95332dbc5d94107a740a66d5ceba46e749116fa9a4707a2b";
    };
    aarch64-darwin = {
      version = "4.27.1";
      revision = "136059";
      date = "";
      arch = "arm64";
      url = "https://desktop.docker.com/mac/main/amd64/${cfg.revision}/Docker.dmg";
      sha256 = "7e2bb9403904078e95332dbc5d94107a740a66d5ceba46e749116fa9a4707a2b";
    };
  };

in {
  options = {
    macOS.apps.docker = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      sourceRoot = mkOption {
        default = "Docker.app";
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
        name = "Docker";
        description = "App to build and share containerized applications and microservices";
        sourceRoot = cfg.sourceRoot;
        version = cfg.version;
        src = pkgs.fetchurl {
          url = cfg.url;
          sha256 = cfg.sha256;
          name = "${(toHyphenedLower name)}-${arch}-${version}.dmg";
        };
        appcast = "https://formulae.brew.sh/api/cask/docker.json";
        homepage = "https://www.docker.com/products/docker-desktop";
      });
  };
}
