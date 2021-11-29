{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.macOS.apps.authy;
in {
  options = {
    macOS.apps.authy = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      version = mkOption {
        default = "1.9.0";
        description = "The version of the app";
      };
      sha256 = mkOption {
        default = "025cq2880rc7svn4a19pcgsljpqcp8qbm6rniwa7aiazyx6wkcbc";
        description = "The sha256 for the defined version";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      (pkgs.callPackage ./lib/app.nix rec {
        name = "Authy";
        appname = "${name} Desktop";
        sourceRoot = "${appname}.app";
        version = cfg.version;
        src = pkgs.fetchurl {
          url = "https://authy-electron-repository-production.s3.amazonaws.com/authy/stable/${version}/darwin/x64/Authy+Desktop-${version}.dmg";
          sha256 = cfg.sha256;
        };
        description = "Two-factor authentication software.";
        homepage = "https://authy.com/";
        appcast = "https://github.com/Homebrew/homebrew-cask/blob/HEAD/Casks/authy.rb";
      });
  };
}
