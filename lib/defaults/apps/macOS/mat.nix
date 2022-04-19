{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.macOS.apps.mat;
  stdenv = pkgs.stdenv;
  arch = if stdenv.isDarwin then stdenv.hostPlatform.darwinArch else stdenv.system;
  toHyphenedLower = str:
    (lib.strings.toLower (builtins.replaceStrings [" "] ["-"] str));
in {
  options = {
    macOS.apps.mat = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      sourceRoot = mkOption {
        default = "mat.app";
        description = "The app folder name to recursively copy from the install archive. e.g., Foo.app";
      };
      version = mkOption {
        default = "1.12.0";
        description = "The version of the app.";
      };
      buildNumber = mkOption {
        default = "20210602";
        description = "The build number of the app (if applicable).";
      };
      sha256 = mkOption {
        default = "f03356398481493b96dcc40502e0fa7e44565c65868fa3c91e24642c8513acdf";
        description = "The sha256 for the app.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages =
      (pkgs.callPackage ./lib/app.nix rec {
        name = "Mat";
        description = "Java heap analyzer";
        sourceRoot = cfg.sourceRoot;
        version = cfg.version;
        src = pkgs.fetchurl {
          url = "https://download.eclipse.org/mat/${cfg.version}/rcp/MemoryAnalyzer-${cfg.version}.${cfg.buildNumber}-macosx.cocoa.x86_64.dmg";
          sha256 = cfg.sha256;
          name = "${(toHyphenedLower name)}-${arch}-${version}.dmg";
        };
        appcast = "https://formulae.brew.sh/api/cask/mat.json";
        homepage = "https://www.eclipse.org/mat/";
      });
  };
}
