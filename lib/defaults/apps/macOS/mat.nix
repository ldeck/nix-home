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
      version = "1.14.0.20230315";
      revision = "";
      date = "";
      arch = "amd64";
      url = "https://download.eclipse.org/mat/${lib.versions.majorMinor cfg.version}.0/rcp/MemoryAnalyzer-${cfg.version}-macosx.cocoa.x86_64.dmg";
      sha256 = "236175bc2f306ec963b708b3b765c1684a018d30da4d38c52c9774b80133ddfb";
    };
    aarch64-darwin = {
      version = "1.14.0.20230315";
      revision = "";
      date = "";
      arch = "arm64";
      url = "https://download.eclipse.org/mat/${lib.versions.majorMinor cfg.version}.0/rcp/MemoryAnalyzer-${cfg.version}-macosx.cocoa.x86_64.dmg";
      sha256 = "236175bc2f306ec963b708b3b765c1684a018d30da4d38c52c9774b80133ddfb";
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
        name = "mat";
        description = "Java heap analyzer";
        sourceRoot = cfg.sourceRoot;
        version = cfg.version;
        src = pkgs.fetchurl {
          url = cfg.url;
          sha256 = cfg.sha256;
          name = "${(toHyphenedLower name)}-${arch}-${version}.dmg";
        };
        appcast = "https://formulae.brew.sh/api/cask/mat.json";
        homepage = "https://eclipse.dev/mat/";
      });
  };
}
