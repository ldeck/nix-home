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
      version = "2.10.38";
      revision = "1";
      date = "";
      arch = "amd64";
      url = "https://download.gimp.org/gimp/v${lib.versions.majorMinor cfg.version}/macos/gimp-${cfg.version}-x86_64-${cfg.revision}.dmg";
      sha256 = "d2d3ac20c762fe12f0dd0ec8d7c6c2f1f3a43e046ecb4ed815a49afcbaa92b92";
      imagetype = "dmg";
    };
    aarch64-darwin = {
      version = "2.10.38";
      revision = "1";
      date = "";
      arch = "arm64";
      url = "https://download.gimp.org/gimp/v${lib.versions.majorMinor cfg.version}/macos/gimp-${cfg.version}-arm64-${cfg.revision}.dmg";
      sha256 = "dc1aa78a40695f9f4580ce710960ff411eeef48af45b659b03b51e4cd6cdf4e8";
      imagetype = "dmg";
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
      imagetype = mkOption {
        default = archSpecs.${stdenv.hostPlatform.system}.imagetype;
        description = "The image type being downloaded.";
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
          name = "${(toHyphenedLower name)}-${arch}-${version}.${cfg.imagetype}";
        };
        appcast = "https://formulae.brew.sh/api/cask/gimp.json";
        homepage = "https://www.gimp.org/";
      });
  };
}
