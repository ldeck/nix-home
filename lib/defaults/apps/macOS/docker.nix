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
      version = "4.3.0";
      revision = "71786";
      arch = "amd64";
      sha256 = "1c988f8df9be1bac6c2ec984aeadbc4b96c2e152ad51aa80af52e15f3e92c4eb";
    };
    aarch64-darwin = {
      version = "4.3.0";
      revision = "71786";
      arch = "arm64";
      sha256 = "b6c5736b277ecbf349319b818bf8bfa9a69b48ef0f0c0c05ffbd6761dc90cd80";
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
