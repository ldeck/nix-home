{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.macOS.apps.docker;
  stdenv = pkgs.stdenv;

  dockerSpecs = {
    x86_64-darwin = {
      version = "4.7.1";
      revision = "77678";
      arch = "amd64";
      sha256 = "194bb59c7015ddea680993be42ee572ccd1a7e4b7f8f00293fa398b98f2926aa";
    };
    aarch64-darwin = {
      version = "4.7.1";
      revision = "77678";
      arch = "arm64";
      sha256 = "ce5aea6a2c30c10a81b9768cfe09c24d4e33a36d355b3703d590ca6c4498e73f";
    };
  };

in {
  options = {
    macOS.apps.docker = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      version = mkOption {
        default = dockerSpecs.${stdenv.hostPlatform.system}.version;
        description = "The version of this app";
      };
      revision = mkOption {
        default = dockerSpecs.${stdenv.hostPlatform.system}.revision;
        description = "The revision of this app";
      };
      arch = mkOption {
        default = dockerSpecs.${stdenv.hostPlatform.system}.arch;
        description = "The architecture for the app";
      };
      sha256 = mkOption {
        default = dockerSpecs.${stdenv.hostPlatform.system}.sha256;
        description = "The sha256 for the defined version";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      (pkgs.callPackage ./lib/app.nix rec {
        name = "Docker";
        sourceRoot = "${name}.app";
        version = cfg.version;
        src = pkgs.fetchurl {
          url = "https://desktop.docker.com/mac/main/${cfg.arch}/${cfg.revision}/${name}.dmg";
          sha256 = cfg.sha256;
        };
        description = ''
          Docker CE for Mac is an easy-to-install desktop app for building,
          debugging, and testing Dockerized apps on a Mac
        '';
        homepage = https://store.docker.com/editions/community/docker-ce-desktop-mac;
        appcast = https://desktop.docker.com/mac/main/amd64/appcast.xml;
        postInstall = ''
          mkdir -p $out/bin
          ln -fs $out/Applications/${name}.app/Contents/Resources/bin/docker* $out/bin/
          #todo: add etc/docker[-compose].[bash|zsh]-completion
        '';
      });
  };
}
