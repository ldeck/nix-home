{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.macOS.apps.gitter;
  stdenv = pkgs.stdenv;
  arch = if stdenv.isDarwin then stdenv.hostPlatform.darwinArch else stdenv.system;
  toHyphenedLower = str:
    (lib.strings.toLower (builtins.replaceStrings [" "] ["-"] str));

  archSpecs = {
    x86_64-darwin = {
      version = "1.177";
      revision = "";
      arch = "amd64";
      sha256 = "0ca1c0d52c342548afbea8d3501282a4ccf494058aa2e23af27e09198a7a30a4";
    };
    aarch64-darwin = {
      version = "1.177";
      revision = "";
      arch = "arm64";
      sha256 = "0ca1c0d52c342548afbea8d3501282a4ccf494058aa2e23af27e09198a7a30a4";
    };
  };

in {
  options = {
    macOS.apps.gitter = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      sourceRoot = mkOption {
        default = "Gitter.app";
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
        name = "Gitter";
        description = "null";
        sourceRoot = cfg.sourceRoot;
        version = cfg.version;
        src = pkgs.fetchurl {
          url = "https://update.gitter.im/osx/Gitter-${cfg.version}.dmg";
          sha256 = cfg.sha256;
          name = "${(toHyphenedLower name)}-${arch}-${version}.dmg";
        };
        appcast = "https://formulae.brew.sh/api/cask/gitter.json";
        homepage = "https://gitter.im/";
      });
  };
}
