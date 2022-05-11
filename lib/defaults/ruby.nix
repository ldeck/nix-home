{ pkgs, lib, config, ... }:

with lib;

let
  cfg = config.programs.ruby-install;
  stdenv = pkgs.stdenv;
  # can't get it to work on darwin purely yet
  gcc = if stdenv.isDarwin then "/usr/bin/gcc" else "${pkgs.gcc}/bin/gcc";
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
            export CC=${gcc}

            SOURCEDIR=" -s ~/.rubies/src "
            OPENSSLDIR=" --with-openssl-dir=${pkgs.openssl.dev} "
            READLINEDIR=" --with-readline-dir=${pkgs.readline.dev} "

            for var in "$@"; do
              case "$var" in
                -s) SOURCEDIR="" ;;
                --with-readline-dir=*) OPENSSLDIR="" ;;
                --with-readline-dir=*) READLINEDIR="" ;;
                *) ;;
              esac
            done

            SWITCHES="$SOURCEDIR"
            CONFIGS="$${OPENSSLDIR}$${READLINEDIR}"
            [ ! -z "$CONFIGS" ] && CONFIGS="-- $CONFIGS"
            ${ruby-install}/bin/ruby-install $SWITCHES $@ $CONFIGS
          '';

        in
          ruby-install-wrapper
      )
    ];
  };
}
