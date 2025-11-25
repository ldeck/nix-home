{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.macOS.apps.chromium;
  stdenv = pkgs.stdenv;
  arch = if stdenv.isDarwin then stdenv.hostPlatform.darwinArch else stdenv.system;
  toHyphenedLower = str:
    (lib.strings.toLower (builtins.replaceStrings [" "] ["-"] str));

  archSpecs = {
    x86_64-darwin = {
      version = "143.0.7499.0";
      revision = "1536380";
      date = "Tue, 28 Oct 2025 02:13:44 GMT";
      arch = "amd64";
      url = "https://storage.googleapis.com/chromium-browser-snapshots/Mac/1536380/chrome-mac.zip";
      sha256 = "02k4f7g171y5mbvay43914700p5dp4i64bz41ldrrm0ab3f6f5sd";
      imagetype = "zip";
    };
    aarch64-darwin = {
      version = "143.0.7499.0";
      revision = "1536380";
      date = "Tue, 28 Oct 2025 02:13:44 GMT";
      arch = "arm64";
      url = "https://storage.googleapis.com/chromium-browser-snapshots/Mac/1536380/chrome-mac.zip";
      sha256 = "02k4f7g171y5mbvay43914700p5dp4i64bz41ldrrm0ab3f6f5sd";
      imagetype = "zip";
    };
  };

in {
  options = {
    macOS.apps.chromium = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      sourceRoot = mkOption {
        default = "chrome-mac/Chromium.app";
        description = "The app folder name to recursively copy from the install archive.";
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
        name = "Chromium";
        description = "Open-source web browser project by Google";
        sourceRoot = cfg.sourceRoot;
        version = cfg.version;
        src = pkgs.fetchurl {
          url = cfg.url;
          sha256 = cfg.sha256;
          name = "${(toHyphenedLower name)}-${arch}-${version}.${cfg.imagetype}";
        };
        appcast = "https://storage.googleapis.com/chromium-browser-snapshots/Mac";
        homepage = "https://www.chromium.org";
      });
  };
}
