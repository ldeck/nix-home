{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  stdenv = pkgs.stdenv;
  cfg = config.macOS.apps.idea-ultimate;

  ideaSpecs = {
    x86_64-darwin = {
      version = "2021.3.2";
      arch = "";
      sha256 = "9f574562b866e6ccc3d2f9b4c245c45844d1d0fd54be3dbdcc893d40ba1cf54a";
    };
    aarch64-darwin = {
      version = "2021.3.2";
      arch = "-aarch64";
      sha256 = "511c6aed9c5cd4c7665a9bac9ba94582977013244cbe88b820eb5464fce91a1c";
    };
  };

in {
  options = {
    macOS.apps.idea-ultimate = {
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
