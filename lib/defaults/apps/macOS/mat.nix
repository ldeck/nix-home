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
        default = "1.11.0.20201202";
        description = "The version of the app";
      };
      arch = mkOption {
        default = "x86_64";
        description = "The architecture for the app bundle";
      };
      sha256 = mkOption {
        default = "0swi65v58n668zfzgyql8kfbpjhyrcq3hhpi637h18d5ba3xivg2";
        description = "The sha256 for the defined version";
      };
    };
  };

  config = {
    home.packages = lib.optionals cfg.enable
      (pkgs.callPackage ./lib/eclipseApp.nix rec {
        name = "MAT";
        sourceRoot = "mat.app";
        majorMinorVersion = lib.majorMinor cfg.version;
        version = cfg.version;
        src = pkgs.fetchurl {
          url = "https://www.eclipse.org/downloads/download.php?r=1&file=/mat/${majorMinorVersion}/rcp/MemoryAnalyzer-${version}-macosx.cocoa.${cfg.arch}.zip";
          sha256 = cfg.sha256;
        };
        description = "The Eclipse Memory Analyzer is a fast and feature-rich Java heap analyzer that helps you find memory leaks and reduce memory consumption.";
        homepage = "https://www.eclipse.org/mat/";
        appcast = "https://www.eclipse.org/mat/downloads.php";
      });
  };
}
