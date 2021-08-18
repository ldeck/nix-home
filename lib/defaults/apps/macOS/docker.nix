{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.macOS.apps.docker;
in {
  options = {
    macOS.apps.docker = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      version = mkOption {
        default = "3.4.0";
        description = "The version of this app";
      };
      revision = mkOption {
        default = "65384";
        description = "The revision of this app";
      };
      arch = mkOption {
        default = "amd64";
        description = "The architecture for the app";
      };
      sha256 = mkOption {
        default = "f6bed5976d1ee223b42986b185626fbc758d5f918aff27d3d7b0c2212406cba9";
        description = "The sha256 for the defined version";
      };
    };
  };

  config = {
    home.packages = lib.optionals cfg.enable
      (pkgs.callPackage ./lib/app.nix rec {
        name = "Docker";
        sourceRoot = "${name}.app";
        version = cfg.version;
        src = pkgs.fetchurl {
          url = "https://desktop.docker.com/mac/stable/${cfg.arch}/${cfg.revision}/${name}.dmg";
          sha256 = cfg.sha256;
        };
        description = ''
          Docker CE for Mac is an easy-to-install desktop app for building,
          debugging, and testing Dockerized apps on a Mac
        '';
        homepage = https://store.docker.com/editions/community/docker-ce-desktop-mac;
        appcast = https://download.docker.com/mac/stable/appcast.xml;
        postInstall = ''
          mkdir -p $out/bin
          ln -fs $out/Applications/${name}.app/Contents/Resources/bin/docker* $out/bin/
          #todo: add etc/docker[-compose].[bash|zsh]-completion
        '';
      });
  };
}
