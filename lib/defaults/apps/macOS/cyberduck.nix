{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.macOS.apps.cyberduck;
in {
  options = {
    macOS.apps.cyberduck = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      version = mkOption {
        default = "8.2.0,36680";
        description = "The version of the app";
      };
      sha256 = mkOption {
        default = "c96c2b99dc5fede4bf3e4f84c7691bf3c2af8ec3db3820361e15f59694593e31";
        description = "The sha256 for the defined version";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      (pkgs.callPackage ./lib/app.nix rec {
        name = "Cyberduck";
        sourceRoot = "Cyberduck.app";
        version = (builtins.head (lib.splitString "," cfg.version));
        fullVersion = (builtins.replaceStrings [","] ["."] cfg.version);
        src = pkgs.fetchurl {
          url = "https://update.cyberduck.io/Cyberduck-${fullVersion}.zip";
          sha256 = cfg.sha256;
        };
        description = "Server and cloud storage browser";
        homepage = https://cyberduck.io/;
        appcast = https://formulae.brew.sh/api/cask/cyberduck.json;
      });
  };
}
