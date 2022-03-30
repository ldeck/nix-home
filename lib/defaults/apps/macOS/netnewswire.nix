{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.macOS.apps.netnewswire;
  arch = if stdenv.isDarwin stdenv.hostPlatform.darwinArch else stdenv.system;
  toHyphenedLower = str:
    (lib.strings.toLower (builtins.replaceStrings [" "] ["-"] str));
in {
  options = {
    macOS.apps.netnewswire = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      sourceRoot = mkOption {
        default = "NetNewsWire.app";
        description = "The app folder name to recursively copy from the install archive. e.g., Foo.app";
      };
      version = mkOption {
        default = "6.0.3";
        description = "The version of the app.";
      };
      sha256 = mkOption {
        default = "d1eaf3776dcc75ad260cfa14bd5b8f6cb3b572c84ac01b545fe6ccf1a609777c";
        description = "The sha256 for the app.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages =
      (pkgs.callPackage ./lib/app.nix rec {
        name = "Netnewswire";
        description = "Free and open-source RSS reader";
        sourceRoot = cfg.sourceRoot;
        version = cfg.version;
        src = pkgs.fetchurl {
          url = "https://github.com/Ranchero-Software/NetNewsWire/releases/download/mac-${cfg.version}/NetNewsWire${cfg.version}.zip";
          sha256 = cfg.sha256;
          name = "${(toHyphenedLower name)}-${arch}-${version}.zip";
        };
        appcast = "https://formulae.brew.sh/api/cask/netnewswire.json";
        homepage = "https://netnewswire.com/";
      });
  };
}
