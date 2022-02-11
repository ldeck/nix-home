{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.macOS.apps.authy;
  inputChars = lib.strings.stringToCharacters "ABCDEFGHIJKLMNOPQRSTUVWXYZ ";
  outputChars = lib.strings.stringToCharacters "abcdefghijklmnopqrstuvwxyz-";
  toHyphenedLower = str: builtins.replaceStrings inputChars outputChars str;
in {
  options = {
    macOS.apps.authy = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      version = mkOption {
        default = "1.9.0";
        description = "The version of the app.";
      };
      sha256 = mkOption {
        default = "6cb1c94df75f4575148f369bba30ba0c5f49f563370545ecd687658090c0ac08";
        description = "The sha256 for the app.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages =
      (pkgs.callPackage ./lib/app.nix rec {
        name = "Authy";
        appName = "${name} Desktop";
        description = "Two-factor authentication software";
        sourceRoot = "${appName}.app";
        version = cfg.version;
        src = pkgs.fetchurl {
          url = "https://authy-electron-repository-production.s3.amazonaws.com/authy/stable/${cfg.version}/darwin/x64/Authy%20Desktop-${cfg.version}.dmg";
          sha256 = cfg.sha256;
          name = "${toHyphenedLower name}-${version}.dmg";
        };
        appcast = "https://formulae.brew.sh/api/cask/authy.json";
        homepage = "https://authy.com/";
      });
  };
}
