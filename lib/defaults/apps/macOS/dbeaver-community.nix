{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.macOS.apps.dbeaver-community;
  stdenv = pkgs.stdenv;
  arch = if stdenv.isDarwin then stdenv.hostPlatform.darwinArch else stdenv.system;
  toHyphenedLower = str:
    (lib.strings.toLower (builtins.replaceStrings [" "] ["-"] str));

  archSpecs = {
    x86_64-darwin = {
      version = "25.1.1";
      revision = "";
      date = "";
      arch = "amd64";
      url = "https://dbeaver.io/files/${cfg.version}/dbeaver-ce-${cfg.version}-macos-aarch64.dmg";
      sha256 = "95fcfe076647681a320ca76e0e7e39a1c493300b12fdb057ac1c8178865bd04c";
      imagetype = "dmg";
    };
    aarch64-darwin = {
      version = "25.1.1";
      revision = "";
      date = "";
      arch = "arm64";
      url = "https://dbeaver.io/files/${cfg.version}/dbeaver-ce-${cfg.version}-macos-aarch64.dmg";
      sha256 = "95fcfe076647681a320ca76e0e7e39a1c493300b12fdb057ac1c8178865bd04c";
      imagetype = "dmg";
    };
  };

in {
  options = {
    macOS.apps.dbeaver-community = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      sourceRoot = mkOption {
        default = "DBeaver.app";
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
        name = "DBeaver";
        description = "Universal database tool and SQL client";
        sourceRoot = cfg.sourceRoot;
        version = cfg.version;
        src = pkgs.fetchurl {
          url = cfg.url;
          sha256 = cfg.sha256;
          name = "${(toHyphenedLower name)}-${arch}-${version}.${cfg.imagetype}";
        };
        appcast = "https://formulae.brew.sh/api/cask/dbeaver-community.json";
        homepage = "https://dbeaver.io/";
      });
  };
}
