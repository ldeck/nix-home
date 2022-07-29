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
      version = "2022.2";
      arch = "";
      sha256 = "45b1ec724c8d72746d2b7f05fd229e6ef68fb82e38f420a1a0ae47faae1086a1";
    };
    aarch64-darwin = {
      version = "2022.2";
      arch = "-aarch64";
      sha256 = "d790aec60c065725d704c834a0cb76fe7643c00186019990688f9a90b64fef3b";
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
