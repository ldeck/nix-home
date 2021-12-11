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
        default = "2.10.28";
        description = "The version of the app";
      };
      arch = mkOption {
        default = "x86_64";
        description = "The arch for the app";
      };
      sha256 = mkOption {
        default = "8cf0db374dcaba6fb0e1184ff8c6a3c585aa1814189ed4b97ba51780469f0805";
        description = "The sha256 for the defined version";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      (pkgs.callPackage ./lib/app.nix rec {
        name = "GIMP";
        sourceRoot = "GIMP-${mainVersion}.app";
        version = cfg.version;
        mainVersion = lib.versions.majorMinor cfg.version;
        src = pkgs.fetchurl {
          url = "https://download.gimp.org/pub/gimp/v${mainVersion}/osx/gimp-${version}-${cfg.arch}.dmg";
          sha256 = cfg.sha256;
        };
        description = "The Free & Open Source Image Editor";
        homepage = "https://www.gimp.org";
        appcast = "https://download.gimp.org/pub/gimp/v#{majorMinorVersion}/osx/";
      });
  };
}
