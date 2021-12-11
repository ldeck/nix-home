{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  stdenv = pkgs.stdenv;
  cfg = config.macOS.apps.postman;

  specs = {
    x86_64-darwin = {
      arch = "osx64";
      sha256 = "800e4afab118a06723fb08e2297bee326b42f602c0ac2711cc77376025fefdb9";
    };
    aarch64-darwin = {
      arch = "osx_arm64";
      sha256 = "144b1884e6747d0e4fb987ddb24999274832fe3d3fa96eeadc6a0be44615a698";
    };
  };

in {
  options = {
    macOS.apps.postman = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      version = mkOption {
        default = "9.4.1";
        description = "The version of the app";
      };
      arch = mkOption {
        default = specs.${stdenv.hostPlatform.system}.arch;
        description = "The bundle architecture type";
      };
      sha256 = mkOption {
        default = specs.${stdenv.hostPlatform.system}.sha256;
        description = "The sha256 for the defined version";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      (pkgs.callPackage ./lib/app.nix rec {
        name = "Postman";
        sourceRoot = "${name}.app";
        version = cfg.version;
        src = pkgs.fetchurl {
          url = "https://dl.pstmn.io/download/version/${version}/${cfg.arch}";
          sha256 = cfg.sha256;
          name = "${name}-${cfg.arch}-${version}.zip";
        };
        description = "Collaboration platform for API development";
        homepage = "https://www.postman.com/";
        appcast = "https://macupdater.net/cgi-bin/check_urls/check_url_filename.cgi?url=https://dl.pstmn.io/download/latest/osx";
      });
  };
}
