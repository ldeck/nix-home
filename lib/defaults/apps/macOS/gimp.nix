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
        default = "2.10.24";
        description = "The version of the app";
      };
      arch = mkOption {
        default = "x86_64";
        description = "The arch for the app";
      };
      sha256 = mkOption {
        default = "d835afd64b4a617516a432a4ff78454594f5147786b4b900371a9fa68252567a";
        description = "The sha256 for the defined version";
      };
    };
  };

  config = {
    home.packages = lib.optionals cfg.enable
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
