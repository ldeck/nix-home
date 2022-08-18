{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.macOS.apps.mat;
  stdenv = pkgs.stdenv;
  arch = if stdenv.isDarwin then stdenv.hostPlatform.darwinArch else stdenv.system;
  toHyphenedLower = str:
    (lib.strings.toLower (builtins.replaceStrings [" "] ["-"] str));

  archSpecs = {
    x86_64-darwin = {
      version = "1.13.0";
      revision = "20220615";
      arch = "amd64";
      sha256 = "5e866ce672f2d800b902f017edc266406ef1c895e6defde0aac5d895d7966b98";
    };
    aarch64-darwin = {
      version = "1.13.0";
      revision = "20220615";
      arch = "arm64";
      sha256 = "55a7113181a5aea34d83a471752f81f27988720e2f58edc090e6e2565f020532";
    };
  };

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
        default = archSpecs.${stdenv.hostPlatform.system}.version;
        description = "The version of the app.";
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
        name = "Mat";
        description = "Java heap analyzer";
        sourceRoot = cfg.sourceRoot;
        version = cfg.version;
        src = pkgs.fetchurl {
          url = "https://download.eclipse.org/mat/${cfg.version}/rcp/MemoryAnalyzer-${cfg.version}.${cfg.revision}-macosx.cocoa.x86_64.dmg";
          sha256 = cfg.sha256;
          name = "${(toHyphenedLower name)}-${arch}-${version}.dmg";
        };
        appcast = "https://formulae.brew.sh/api/cask/mat.json";
        homepage = "https://www.eclipse.org/mat/";
      });
  };
}
