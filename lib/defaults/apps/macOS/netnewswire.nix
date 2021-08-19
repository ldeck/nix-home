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
        default = "6.0.2";
        description = "The version of the app";
      };
      sha256 = mkOption {
        default = "bf3f78a2d4552a022a17a4117ad819508a025b51c79e1905bcd44233331d1eed";
        description = "The sha256 for the defined version";
      };
    };
  };

  config = {
    home.packages = lib.optionals cfg.enable
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
