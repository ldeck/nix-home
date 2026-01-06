{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.macOS.apps.tuple;
  stdenv = pkgs.stdenv;
  arch = if stdenv.isDarwin then stdenv.hostPlatform.darwinArch else stdenv.system;
  toHyphenedLower = str:
    (lib.strings.toLower (builtins.replaceStrings [" "] ["-"] str));

  archSpecs = {
    x86_64-darwin = {
      version = "2.1.2";
      revision = "42dc047bd";
      date = "2025-12-22";
      arch = "amd64";
      url = "https://d32ifkf9k9ezcg.cloudfront.net/production/sparkle/tuple-${cfg.version}-${cfg.date}-${cfg.revision}.zip";
      sha256 = "6cc2b178ee8420e848188cc02ae3bbad7a3104c06ee36bb2e18c1da29aa0097d";
      imagetype = "zip";
    };
    aarch64-darwin = {
      version = "2.1.2";
      revision = "42dc047bd";
      date = "2025-12-22";
      arch = "arm64";
      url = "https://d32ifkf9k9ezcg.cloudfront.net/production/sparkle/tuple-${cfg.version}-${cfg.date}-${cfg.revision}.zip";
      sha256 = "6cc2b178ee8420e848188cc02ae3bbad7a3104c06ee36bb2e18c1da29aa0097d";
      imagetype = "zip";
    };
  };

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
        name = "Tuple";
        description = "Remote pair programming app";
        sourceRoot = cfg.sourceRoot;
        version = cfg.version;
        src = pkgs.fetchurl {
          url = cfg.url;
          sha256 = cfg.sha256;
          name = "${(toHyphenedLower name)}-${arch}-${version}.${cfg.imagetype}";
        };
        appcast = "https://formulae.brew.sh/api/cask/tuple.json";
        homepage = "https://tuple.app/";
      });
  };
}
