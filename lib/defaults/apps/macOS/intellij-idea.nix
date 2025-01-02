{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.macOS.apps.intellij-idea;
  stdenv = pkgs.stdenv;
  arch = if stdenv.isDarwin then stdenv.hostPlatform.darwinArch else stdenv.system;
  toHyphenedLower = str:
    (lib.strings.toLower (builtins.replaceStrings [" "] ["-"] str));

  archSpecs = {
    x86_64-darwin = {
      version = "2024.3.1.1";
      revision = "243.22562.218";
      date = "";
      arch = "amd64";
      url = "https://download.jetbrains.com/idea/ideaIU-${cfg.version}.dmg";
      sha256 = "eca0be9cd1d35df6453075dd447c8945d97134b90d1de4313e9b98069d3a39a3";
      imagetype = "dmg";
    };
    aarch64-darwin = {
      version = "2024.3.1.1";
      revision = "243.22562.218";
      date = "";
      arch = "arm64";
      url = "https://download.jetbrains.com/idea/ideaIU-${cfg.version}-aarch64.dmg";
      sha256 = "308773c0f5d15754fbdf1bbaf2155e34b8808880afdee55e5ac8bad8d477162d";
      imagetype = "dmg";
    };
  };

in {
  options = {
    macOS.apps.intellij-idea = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      sourceRoot = mkOption {
        default = "IntelliJ IDEA.app";
        description = "The app folder name to recursively copy from the install archive. e.g., Foo.app";
      };
      version = mkOption {
        default = archSpecs.${stdenv.hostPlatform.system}.version;
        description = "The version of the app.";
      };
      date = mkOption {
        default = archSpecs.${stdenv.hostPlatform.system}.date;
        description = "The build date (if applicable).";
      };
      revision = mkOption {
        default = archSpecs.${stdenv.hostPlatform.system}.revision;
        description = "The build number of the app (if applicable).";
      };
      url = mkOption {
        default = archSpecs.${stdenv.hostPlatform.system}.url;
        description = "The url or url template for the archive.";
      };
      sha256 = mkOption {
        default = archSpecs.${stdenv.hostPlatform.system}.sha256;
        description = "The sha256 for the app.";
      };
      imagetype = mkOption {
        default = archSpecs.${stdenv.hostPlatform.system}.imagetype;
        description = "The image type being downloaded.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages =
      (pkgs.callPackage ./lib/app.nix rec {
        name = "IntelliJ IDEA";
        description = "Java IDE by JetBrains";
        sourceRoot = cfg.sourceRoot;
        version = cfg.version;
        src = pkgs.fetchurl {
          url = cfg.url;
          sha256 = cfg.sha256;
          name = "${(toHyphenedLower name)}-${arch}-${version}.${cfg.imagetype}";
        };
        appcast = "https://formulae.brew.sh/api/cask/intellij-idea.json";
        homepage = "https://www.jetbrains.com/idea/";
      });
  };
}
