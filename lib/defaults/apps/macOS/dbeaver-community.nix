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
      version = "23.2.2";
      revision = "";
      date = "";
      arch = "amd64";
      url = "https://dbeaver.io/files/${cfg.version}/dbeaver-ce-${cfg.version}-macos-x86_64.dmg";
      sha256 = "5dc1e8ce7f243073bfd375e49f0a873c239a34d4908ba554e7f562a4f4fb86b7";
    };
    aarch64-darwin = {
      version = "23.2.2";
      revision = "";
      date = "";
      arch = "arm64";
      url = "https://dbeaver.io/files/${cfg.version}/dbeaver-ce-${cfg.version}-macos-aarch64.dmg";
      sha256 = "10d4f01c1cbf9bc136842d311c55fa072c1e3a48d1f510fe7a6039b4c4e2e266";
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
          name = "${(toHyphenedLower name)}-${arch}-${version}.dmg";
        };
        appcast = "https://formulae.brew.sh/api/cask/dbeaver-community.json";
        homepage = "https://dbeaver.io/";
      });
  };
}
