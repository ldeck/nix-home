{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.macOS.apps.netnewswire;
in {
  options = {
    macOS.apps.netnewswire = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      version = mkOption {
        default = "6.0.3";
        description = "The version of the app";
      };
      sha256 = mkOption {
        default = "0z3p16kg3k76bxa1ph2ar1rbbcvcixdvs57s1hkasxfcdmvz7sni";
        description = "The sha256 for the defined version";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      (pkgs.callPackage ./lib/app.nix rec {
        name = "NetNewsWire";
        sourceRoot = "NetNewsWire.app";
        version = cfg.version;
        src = pkgs.fetchurl {
          url = "https://github.com/Ranchero-Software/${name}/releases/download/mac-${version}/${name}${version}.zip";
          sha256 = cfg.sha256;
          name = "${name}-${version}.zip";
        };
        description = "Free and open-source RSS reader";
        homepage = "https://netnewswire.com/";
        appcast = "https://formulae.brew.sh/api/cask/netnewswire.json";
      });
  };
}
