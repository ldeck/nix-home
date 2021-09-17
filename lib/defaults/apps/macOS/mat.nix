{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.macOS.apps.mat;
in {
  options = {
    macOS.apps.mat = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      version = mkOption {
        default = "1.12.0.20210602";
        description = "The version of the app";
      };
      arch = mkOption {
        default = "x86_64";
        description = "The architecture for the app bundle";
      };
      sha256 = mkOption {
        default = "1pxc2f2jqr143v4s73w6cmf5ci3yzbh041f4vjb3njc1hhwmcczh";
        description = "The sha256 for the defined version";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      (pkgs.callPackage ./lib/eclipseApp.nix rec {
        name = "MAT";
        sourceRoot = "mat.app";
        mainVersion = with lib.versions; (majorMinor cfg.version) + "." + (patch cfg.version);
        version = cfg.version;
        src = pkgs.fetchurl {
          url = "https://www.eclipse.org/downloads/download.php?r=1&file=/mat/${mainVersion}/rcp/MemoryAnalyzer-${version}-macosx.cocoa.${cfg.arch}.dmg";
          sha256 = cfg.sha256;
        };
        description = "The Eclipse Memory Analyzer is a fast and feature-rich Java heap analyzer that helps you find memory leaks and reduce memory consumption.";
        homepage = "https://www.eclipse.org/mat/";
        appcast = "https://www.eclipse.org/mat/downloads.php";
      });
  };
}
