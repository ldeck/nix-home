{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.macOS.apps.vnc-viewer;
  stdenv = pkgs.stdenv;
  arch = if stdenv.isDarwin then stdenv.hostPlatform.darwinArch else stdenv.system;
  toHyphenedLower = str:
    (lib.strings.toLower (builtins.replaceStrings [" "] ["-"] str));

  archSpecs = {
    x86_64-darwin = {
      version = "7.13.1";
      revision = "";
      date = "";
      arch = "amd64";
      url = "https://downloads.realvnc.com/download/file/viewer.files/VNC-Viewer-${cfg.version}-MacOSX-universal.dmg";
      sha256 = "59177c10479e7d773a2df82d58a4f73b056d1c354b85b11b1040218b3c10419c";
      imagetype = "dmg";
    };
    aarch64-darwin = {
      version = "7.13.1";
      revision = "";
      date = "";
      arch = "arm64";
      url = "https://downloads.realvnc.com/download/file/viewer.files/VNC-Viewer-${cfg.version}-MacOSX-universal.dmg";
      sha256 = "59177c10479e7d773a2df82d58a4f73b056d1c354b85b11b1040218b3c10419c";
      imagetype = "dmg";
    };
  };

in {
  options = {
    macOS.apps.vnc-viewer = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      sourceRoot = mkOption {
        default = "VNC Viewer.app";
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
        name = "VNC Viewer";
        description = "Remote desktop application focusing on security";
        sourceRoot = cfg.sourceRoot;
        version = cfg.version;
        src = pkgs.fetchurl {
          url = cfg.url;
          sha256 = cfg.sha256;
          name = "${(toHyphenedLower name)}-${arch}-${version}.${cfg.imagetype}";
        };
        appcast = "https://formulae.brew.sh/api/cask/vnc-viewer.json";
        homepage = "https://www.realvnc.com/";
      });
  };
}
