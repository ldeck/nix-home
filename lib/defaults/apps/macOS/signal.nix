{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.macOS.apps.signal;
  stdenv = pkgs.stdenv;
  arch = if stdenv.isDarwin then stdenv.hostPlatform.darwinArch else stdenv.system;
  toHyphenedLower = str:
    (lib.strings.toLower (builtins.replaceStrings [" "] ["-"] str));

  archSpecs = {
    x86_64-darwin = {
      version = "6.36.0";
      revision = "";
      date = "";
      arch = "amd64";
      url = "https://updates.signal.org/desktop/signal-desktop-mac-x64-${cfg.version}.dmg";
      sha256 = "6d4839d9b6ab7ac292b0d384931128be5364b210c6b295ba33fe6e7abfb1768d";
    };
    aarch64-darwin = {
      version = "6.36.0";
      revision = "";
      date = "";
      arch = "arm64";
      url = "https://updates.signal.org/desktop/signal-desktop-mac-x64-${cfg.version}.dmg";
      sha256 = "6d4839d9b6ab7ac292b0d384931128be5364b210c6b295ba33fe6e7abfb1768d";
    };
  };

in {
  options = {
    macOS.apps.signal = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      sourceRoot = mkOption {
        default = "Signal.app";
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
        name = "Signal";
        description = "Instant messaging application focusing on security";
        sourceRoot = cfg.sourceRoot;
        version = cfg.version;
        src = pkgs.fetchurl {
          url = cfg.url;
          sha256 = cfg.sha256;
          name = "${(toHyphenedLower name)}-${arch}-${version}.dmg";
        };
        appcast = "https://formulae.brew.sh/api/cask/signal.json";
        homepage = "https://signal.org/";
      });
  };
}
