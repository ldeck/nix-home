{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.macOS.apps.cyberduck;
  stdenv = pkgs.stdenv;
  arch = if stdenv.isDarwin then stdenv.hostPlatform.darwinArch else stdenv.system;
  toHyphenedLower = str:
    (lib.strings.toLower (builtins.replaceStrings [" "] ["-"] str));

  archSpecs = {
    x86_64-darwin = {
      version = "8.7.0";
      revision = "40629";
      date = "";
      arch = "amd64";
      url = "https://update.cyberduck.io/Cyberduck-${cfg.version}.${cfg.revision}.zip";
      sha256 = "0076129b8e3d702e90d33450260116e0ca6711b8fbc59413799aa332235614bb";
    };
    aarch64-darwin = {
      version = "8.7.0";
      revision = "40629";
      date = "";
      arch = "arm64";
      url = "https://update.cyberduck.io/Cyberduck-${cfg.version}.${cfg.revision}.zip";
      sha256 = "0076129b8e3d702e90d33450260116e0ca6711b8fbc59413799aa332235614bb";
    };
  };

in {
  options = {
    macOS.apps.cyberduck = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      sourceRoot = mkOption {
        default = "Cyberduck.app";
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
        name = "Cyberduck";
        description = "Server and cloud storage browser";
        sourceRoot = cfg.sourceRoot;
        version = cfg.version;
        src = pkgs.fetchurl {
          url = cfg.url;
          sha256 = cfg.sha256;
          name = "${(toHyphenedLower name)}-${arch}-${version}.zip";
        };
        appcast = "https://formulae.brew.sh/api/cask/cyberduck.json";
        homepage = "https://cyberduck.io/";
      });
  };
}
