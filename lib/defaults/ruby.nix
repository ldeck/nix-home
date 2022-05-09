{ pkgs, lib, config, ... }:

with lib;

let
  cfg = config.programs.ruby-install;
  stdenv = pkgs.stdenv;

in
{
  options = {
    programs.ruby-install = {
      enable = mkOption {
        default = false;
        description = "Whether to enable ruby-install.";
      };
      version = mkOption {
        default = "0.8.3";
        description = "The version of ruby-install.";
      };
      sha256 = mkOption {
        default = "EJISa4q1tATAZ2E5CkBeOMskGG0DF2ewNnhGfGCKrkE=";
        description = "The sha256 for ruby-install.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = [
      (
        let
          ruby-install = stdenv.mkDerivation rec {
            name = "ruby-install-${version}";
            version = cfg.version;

            src = pkgs.fetchFromGitHub {
              owner = "postmodern";
              repo = "ruby-install";
              rev = "v${version}";
              sha256 = cfg.sha256;
            };

            buildInputs = with pkgs; [
              coreutils
            ];

            makeFlags = [
              "PREFIX=$(out)"
              "SHELL=${pkgs.bash}/bin/bash"
            ];

            preInstall = ''
              mkdir -p $out/bin
              mkdir -p $out/share
            '';
          };

          ruby-install-wrapper = pkgs.writeShellScriptBin "ruby-install" ''
            export CC=${pkgs.gcc}/bin/gcc
            export RUBY_CONFIGURE_OPTS="--with-openssl-dir=${pkgs.openssl_3_0} --with-readline-dir=${pkgs.readline}"
            ${ruby-install}/bin/ruby-install $@
          '';

        in

          ruby-install-wrapper
      )
    ];
  };
}
