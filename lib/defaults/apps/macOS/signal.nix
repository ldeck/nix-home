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
      version = "5.54.0";
      revision = "";
      arch = "amd64";
      sha256 = "af1f384ba44767f6416fa23b9149329e491f9c151ca3c8bc75e7c61a8faf1306";
    };
    aarch64-darwin = {
      version = "5.54.0";
      revision = "";
      arch = "arm64";
      sha256 = "c18ed71e164316122053ab037249583d84cc9baa7fc088427735ec08881c51b0";
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
        name = "Signal";
        description = "Instant messaging application focusing on security";
        sourceRoot = cfg.sourceRoot;
        version = cfg.version;
        src = pkgs.fetchurl {
          url = "https://updates.signal.org/desktop/signal-desktop-mac-x64-${cfg.version}.dmg";
          sha256 = cfg.sha256;
          name = "${(toHyphenedLower name)}-${arch}-${version}.dmg";
        };
        appcast = "https://formulae.brew.sh/api/cask/signal.json";
        homepage = "https://signal.org/";
      });
  };
}
