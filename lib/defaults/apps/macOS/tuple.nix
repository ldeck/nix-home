{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.macOS.apps.tuple;
  stdenv = pkgs.stdenv;
  arch = if stdenv.isDarwin then stdenv.hostPlatform.darwinArch else stdenv.system;
  toHyphenedLower = str:
    (lib.strings.toLower (builtins.replaceStrings [" "] ["-"] str));
in {
  options = {
    macOS.apps.tuple = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      sourceRoot = mkOption {
        default = "Tuple.app";
        description = "The app folder name to recursively copy from the install archive. e.g., Foo.app";
      };
      version = mkOption {
        default = "0.96.2";
        description = "The version of the app.";
      };
      buildDate = mkOption {
        default = "2022-04-14";
        description = "The date of the release build.";
      };
      buildNumber = mkOption {
        default = "68dcf1f46";
        description = "The build number associated with the build.";
      };
      sha256 = mkOption {
        default = "MZMS2V0Hdr6HyL4tXokV4jDWvFS+1XxAvXa2fjl1faI=";
        description = "The sha256 for the app.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages =
      (pkgs.callPackage ./lib/app.nix rec {
        name = "Tuple";
        description = "Remote pair programming app";
        sourceRoot = cfg.sourceRoot;
        version = cfg.version;
        src = pkgs.fetchurl {
          url = "https://d32ifkf9k9ezcg.cloudfront.net/production/sparkle/tuple-${cfg.version}-${cfg.buildDate}-${cfg.buildNumber}.zip";
          sha256 = cfg.sha256;
          name = "${(toHyphenedLower name)}-${arch}-${version}.zip";
        };
        appcast = "https://formulae.brew.sh/api/cask/tuple.json";
        homepage = "https://tuple.app/";
      });
  };
}
