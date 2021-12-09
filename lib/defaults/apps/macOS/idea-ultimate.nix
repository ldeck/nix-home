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
      version = "2021.3";
      arch = "";
      sha256 = "463e861c5357bef19f498f4bffa06f7e912d59f7a795eda2c603b02d4d737de0";
    };
    aarch64-darwin = {
      version = "2021.3";
      arch = "-aarch64";
      sha256 = "9f9186b9a9ac97c656fb3f40fd0880e0d84957e66e19e72a20d6f15d2cd92b41";
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
