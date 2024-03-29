{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.macOS.apps.gimp;
  stdenv = pkgs.stdenv;
  arch = if stdenv.isDarwin then stdenv.hostPlatform.darwinArch else stdenv.system;
  toHyphenedLower = str:
    (lib.strings.toLower (builtins.replaceStrings [" "] ["-"] str));

  archSpecs = {
    x86_64-darwin = {
      version = "2.10.36";
      revision = "";
      date = "";
      arch = "amd64";
      url = "https://download.gimp.org/gimp/v${lib.versions.majorMinor cfg.version}/macos/gimp-${cfg.version}-x86_64.dmg";
      sha256 = "9e6e4f9572d1509cbb7f442b01232428adbfa45cb99f92a6d497b2f25ae9327e";
    };
    aarch64-darwin = {
      version = "2.10.36";
      revision = "";
      date = "";
      arch = "arm64";
      url = "https://download.gimp.org/gimp/v${lib.versions.majorMinor cfg.version}/macos/gimp-${cfg.version}-x86_64.dmg";
      sha256 = "9e6e4f9572d1509cbb7f442b01232428adbfa45cb99f92a6d497b2f25ae9327e";
    };
  };

in {
  options = {
    macOS.apps.gimp = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      sourceRoot = mkOption {
        default = "GIMP.app";
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
        name = "GIMP";
        description = "Free and open-source image editor";
        sourceRoot = cfg.sourceRoot;
        version = cfg.version;
        src = pkgs.fetchurl {
          url = cfg.url;
          sha256 = cfg.sha256;
          name = "${(toHyphenedLower name)}-${arch}-${version}.dmg";
        };
        appcast = "https://formulae.brew.sh/api/cask/gimp.json";
        homepage = "https://www.gimp.org/";
      });
  };
}
