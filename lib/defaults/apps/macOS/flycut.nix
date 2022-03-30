{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.macOS.apps.flycut;
  arch = if stdenv.isDarwin stdenv.hostPlatform.darwinArch else stdenv.system;
  toHyphenedLower = str:
    (lib.strings.toLower (builtins.replaceStrings [" "] ["-"] str));
in {
  options = {
    macOS.apps.flycut = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      sourceRoot = mkOption {
        default = "Flycut.app";
        description = "The app folder name to recursively copy from the install archive. e.g., Foo.app";
      };
      version = mkOption {
        default = "1.9.6";
        description = "The version of the app.";
      };
      sha256 = mkOption {
        default = "bc1a73b9cb4b4d316fa11572f43383f0f02fc7e6ba88bbed046cc1b074336862";
        description = "The sha256 for the app.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages =
      (pkgs.callPackage ./lib/app.nix rec {
        name = "Flycut";
        description = "Clipboard manager for developers";
        sourceRoot = cfg.sourceRoot;
        version = cfg.version;
        src = pkgs.fetchurl {
          url = "https://github.com/TermiT/Flycut/releases/download/${cfg.version}/Flycut.${cfg.version}.zip";
          sha256 = cfg.sha256;
          name = "${(toHyphenedLower name)}-${arch}-${version}.zip";
        };
        appcast = "https://formulae.brew.sh/api/cask/flycut.json";
        homepage = "https://github.com/TermiT/Flycut";
      });
  };
}
