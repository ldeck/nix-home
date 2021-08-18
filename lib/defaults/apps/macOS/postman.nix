{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.macOS.apps.postman;
in {
  options = {
    macOS.apps.postman = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      version = mkOption {
        default = "8.6.1";
        description = "The version of the app";
      };
      arch = mkOption {
        default = "osx64";
        description = "The bundle architecture type";
      };
      sha256 = mkOption {
        default = "1jywsx3fgjgj8rvqzp02nnza545svcsk45jdxvyna13ddnmldkvi";
        description = "The sha256 for the defined version";
      };
    };
  };

  config = {
    home.packages = lib.optionals cfg.enable
      (pkgs.callPackage ./lib/app.nix rec {
        name = "Postman";
        sourceRoot = "${name}.app";
        version = cfg.version;
        src = pkgs.fetchurl {
          url = "https://dl.pstmn.io/download/version/${version}/osx64";
          sha256 = cfg.sha256;
          name = "${name}-osx-${version}.zip";
        };
        description = "Collaboration platform for API development";
        homepage = "https://www.postman.com/";
        appcast = "https://macupdater.net/cgi-bin/check_urls/check_url_filename.cgi?url=https://dl.pstmn.io/download/latest/osx";
      });
  };
}
