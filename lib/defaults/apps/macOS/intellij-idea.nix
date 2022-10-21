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
      version = "2022.2.3";
      arch = "";
      sha256 = "df780c841398532e090adc2c6af35a7fbcdd29fddb37e5a68f33d61a9032d5a3";
    };
    aarch64-darwin = {
      version = "2022.2.3";
      arch = "-aarch64";
      sha256 = "9e5c32fffd17d651d8d875c2588a067902a9ebb9bf815d06aabfd75b9f4ee3cd";
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
