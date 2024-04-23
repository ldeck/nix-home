{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.macOS.apps.authy;
  stdenv = pkgs.stdenv;
  arch = if stdenv.isDarwin then stdenv.hostPlatform.darwinArch else stdenv.system;
  toHyphenedLower = str:
    (lib.strings.toLower (builtins.replaceStrings [" "] ["-"] str));

  archSpecs = {
    x86_64-darwin = {
      version = "2.5.0";
      revision = "";
      date = "";
      arch = "amd64";
      url = "https://pkg.authy.com/authy/stable/${cfg.version}/darwin/x64/Authy%20Desktop-${cfg.version}.dmg";
      sha256 = "7116fa3638eedc66f947acbd75380e1e0f10e0d7e71369e3bb39ce99f8299455";
      imagetype = "dmg";
    };
    aarch64-darwin = {
      version = "2.5.0";
      revision = "";
      date = "";
      arch = "arm64";
      url = "https://pkg.authy.com/authy/stable/${cfg.version}/darwin/x64/Authy%20Desktop-${cfg.version}.dmg";
      sha256 = "7116fa3638eedc66f947acbd75380e1e0f10e0d7e71369e3bb39ce99f8299455";
      imagetype = "dmg";
    };
  };

in {
  options = {
    macOS.apps.authy = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      sourceRoot = mkOption {
        default = "Authy Desktop.app";
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
        name = "Authy Desktop";
        description = "Two-factor authentication software";
        sourceRoot = cfg.sourceRoot;
        version = cfg.version;
        src = pkgs.fetchurl {
          url = cfg.url;
          sha256 = cfg.sha256;
          name = "${(toHyphenedLower name)}-${arch}-${version}.${cfg.imagetype}";
        };
        appcast = "https://formulae.brew.sh/api/cask/authy.json";
        homepage = "https://authy.com/";
      });
  };
}
