{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.macOS.apps.gimp;
in {
  options = {
    macOS.apps.gimp = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      version = mkOption {
        default = "2.10.22";
        description = "The version of the app";
      };
      arch = mkOption {
        default = "x68_64";
        description = "The arch for the app";
      };
      sha256 = mkOption {
        default = "102jm60bgnymm9xsdggg6bsfvqd3m81jxpy7q4j562cwmpw2nfwf";
        description = "The sha256 for the defined version";
      };
    };
  };

  config = {
    home.packages = lib.optionals cfg.enable
      (pkgs.callPackage ./lib/app.nix rec {
        name = "GIMP";
        majorMinorVersion = lib.majorMinor cfg.version;
        sourceRoot = "GIMP-${majorMinorVersion}.app";
        version = cfg.version;
        src = pkgs.fetchurl {
          url = "https://download.gimp.org/pub/gimp/v${majorMinorVersion}/osx/gimp-${version}-${cfg.arch}.dmg";
          sha256 = cfg.sha256;
        };
        description = "The Free & Open Source Image Editor";
        homepage = "https://www.gimp.org";
        appcast = "https://download.gimp.org/pub/gimp/v#{majorMinorVersion}/osx/";
      });
  };
}
