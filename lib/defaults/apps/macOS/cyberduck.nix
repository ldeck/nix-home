{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.macOS.apps.cyberduck;
  stdenv = pkgs.stdenv;
  arch = if stdenv.isDarwin then stdenv.hostPlatform.darwinArch else stdenv.system;
  toHyphenedLower = str:
    (lib.strings.toLower (builtins.replaceStrings [" "] ["-"] str));

  archSpecs = {
    x86_64-darwin = {
      version = "9.1.6";
      revision = "43284";
      date = "";
      arch = "amd64";
      url = "https://update.cyberduck.io/Cyberduck-${cfg.version}.${cfg.revision}.zip";
      sha256 = "86a7a7da7b9d515d81f84bc7c221d2f07521c83183ff977d27e2bf50b4855e30";
      imagetype = "zip";
    };
    aarch64-darwin = {
      version = "9.1.6";
      revision = "43284";
      date = "";
      arch = "arm64";
      url = "https://update.cyberduck.io/Cyberduck-${cfg.version}.${cfg.revision}.zip";
      sha256 = "86a7a7da7b9d515d81f84bc7c221d2f07521c83183ff977d27e2bf50b4855e30";
      imagetype = "zip";
    };
  };

in {
  options = {
    macOS.apps.cyberduck = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      sourceRoot = mkOption {
        default = "Cyberduck.app";
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
        name = "Cyberduck";
        description = "Server and cloud storage browser";
        sourceRoot = cfg.sourceRoot;
        version = cfg.version;
        src = pkgs.fetchurl {
          url = cfg.url;
          sha256 = cfg.sha256;
          name = "${(toHyphenedLower name)}-${arch}-${version}.${cfg.imagetype}";
        };
        appcast = "https://formulae.brew.sh/api/cask/cyberduck.json";
        homepage = "https://cyberduck.io/";
      });
  };
}
