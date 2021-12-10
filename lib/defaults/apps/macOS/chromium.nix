{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  stdenv = pkgs.stdenv;
  cfg = config.macOS.apps.chromium;

  specs = {
    x86_64-darwin = {
      version = "948906";
      arch = "Mac";
      sha256 = "dee4dbb296e672d2e7e552d865d82c3248b2534b232ee638f472aa3a8948b223";
    };
    aarch64-darwin = {
      version = "948906";
      arch = "Mac_Arm";
      sha256 = "823c1c56a981619d4a1fb029ba415ab6a0d47caf70c70d337d64651a2e6d82d9";
    };
  };

in {
  options = {
    macOS.apps.chromium = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      arch = mkOption {
        default = specs.${stdenv.hostPlatform.system}.arch;
        description = "The chromium alias for the host platform's system. e.g., Mac, Mac_Arm";
      };
      version = mkOption {
        default = specs.${stdenv.hostPlatform.system}.version;
        description = "The version of this app";
      };
      sha256 = mkOption {
        default = specs.${stdenv.hostPlatform.system}.sha256;
        description = "The sha256 for the defined version";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      (pkgs.callPackage ./lib/app.nix rec {
        name = "Chromium";
        sourceRoot = "chrome-mac/${name}.app";
        version = cfg.version;
        src = pkgs.fetchurl {
          url = "https://commondatastorage.googleapis.com/chromium-browser-snapshots/${cfg.arch}/${version}/chrome-mac.zip";
          sha256 = cfg.sha256;
        };
        description = "Chromium is an open-source browser project that aims to build a safer, faster, and more stable way for all Internet users to experience the web.";
      homepage = "https://chromium.org/Home";
      appcast = "https://chromiumdash.appspot.com/releases?platform=Mac";
      });
  };
}
