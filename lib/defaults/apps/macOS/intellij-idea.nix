{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  stdenv = pkgs.stdenv;
  cfg = config.macOS.apps.intellij-idea;

  ideaSpecs = {
    x86_64-darwin = {
      version = "2022.1.3";
      arch = "";
      sha256 = "7297867bb7c5041015ff2e68415e35537c37bf500c53a5e003c82fc6af9515ab";
    };
    aarch64-darwin = {
      version = "2022.1.3";
      arch = "-aarch64";
      sha256 = "0f0ec167c0394b7d4969cb0b95e08e2b469e811a1aa515971bc84d5ef4d54def";
    };
  };

in {
  options = {
    macOS.apps.intellij-idea = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      version = mkOption {
        default = ideaSpecs.${stdenv.hostPlatform.system}.version;
        description = "The version of the app";
      };
      sha256 = mkOption {
        default = ideaSpecs.${stdenv.hostPlatform.system}.sha256;
        description = "The sha256 for the defined version";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      (pkgs.callPackage ./lib/app.nix rec {
        name = "IntelliJIDEA";
        sourceRoot = "IntelliJ IDEA.app";
        version = cfg.version;
        arch = if pkgs.stdenv.isAarch64 then "-aarch64" else "";
        src = pkgs.fetchurl {
          url = "https://download.jetbrains.com/idea/ideaIU-${version}${arch}.dmg";
          sha256 = cfg.sha256;
        };
        description = "The most intelligent JVM IDE";
        homepage = https://www.jetbrains.com/idea/;
        appcast = https://www.jetbrains.com/idea/download/other.html;
      });
  };
}
