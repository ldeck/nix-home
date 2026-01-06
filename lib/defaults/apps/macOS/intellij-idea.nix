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
      version = "2025.3.1";
      revision = "253.29346.138";
      date = "";
      arch = "amd64";
      url = "https://download.jetbrains.com/idea/ideaIU-${cfg.version}.dmg";
      sha256 = "adf5af3839e07ba6387bf0eca94df2f44c829023a1898170eacbc5cbafce0393";
      imagetype = "dmg";
    };
    aarch64-darwin = {
      version = "2025.3.1";
      revision = "253.29346.138";
      date = "";
      arch = "arm64";
      url = "https://download.jetbrains.com/idea/ideaIU-${cfg.version}-aarch64.dmg";
      sha256 = "2137863cc3a5f4acd25ba38a82e004e935d3a94fa566f8e3851d6b8a8ac12777";
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
