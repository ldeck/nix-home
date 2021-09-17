{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.macOS.apps.tibcojaspersoftstudio;
in {
  options = {
    macOS.apps.tibcojaspersoftstudio = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      version = mkOption {
        default = "6.17.0";
        description = "The version of the app.";
      };
      arch = mkOption {
        default = "x86_64";
        description = "The selected binary architecture.";
      };
      sha256 = mkOption {
        default = "0cayzfwr8w2p6ha2rhmb5jl42a0qlrw1gyk6dnc2hf71fvfm51p5";
        description = "The sha256 for the defined version";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      (pkgs.callPackage ./lib/app.nix rec {
        name = "TibcoJaspersoftStudio";
        appname = "Tibco Jaspersoft Studio";
        version = cfg.version;
        sourceRoot = "TIBCO Jaspersoft Studio ${version}.app";
        src = pkgs.fetchurl {
          url = "https://downloads.sourceforge.net/jasperstudio/JaspersoftStudio-${version}/TIB_js-studiocomm_${version}_macosx_${cfg.arch}.dmg";
          sha256 = cfg.sha256;
        };
        description = "The Eclipse-based report development tool for JasperReports and JasperReports Server";
        homepage = https://community.jaspersoft.com/project/jaspersoft-studio;
        appcast = https://sourceforge.net/projects/jasperstudio/rss;
      });
  };
}
