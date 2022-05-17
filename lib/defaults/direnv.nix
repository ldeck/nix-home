{ pkgs, lib, config, ... }:

with lib;

let

  cfg = config.programs.direnv;

  java_home = pkgs.writeShellScriptBin "java_home" ''
    if [ "$#" -ne 2 ] || [ "$1" != "-v" ] || [ "$2" -lt 8 ]; then
        echo "Usage: java_home -v <version>";
        exit 1;
      fi
      case "$2" in
        8)
          JDK="${pkgs.jdk8_headless}"
          ;;
        11)
          JDK="${pkgs.jdk11_headless}"
          ;;
        *)
          JDK="${pkgs.jdk17_headless}"
          ;;
      esac
      JAVA_HOME=$(${pkgs.coreutils}/bin/realpath "$JDK/bin/..")
      echo "$JAVA_HOME"
  '';

in
{
  options = {
    programs.direnv = {
      use_java = {
        enable = mkOption {
          default = false;
          description = "Whether to enable direnv use_java";
        };
        script = mkOption {
          type = types.str;
          default = ''
            use_java() {
              # desired jdk version as first parameter?
              local ver=$1

              # if version not given as param, check for .java-version file
              if [[ -z $ver ]] && [[ -f .java-version ]]; then
                ver=$(cat .java-version)
              fi

              # if the version still isn't set, set warning
              if [[ -z $ver ]]; then
                echo Warning: This project does not specify a JDK version! Using 17.
                ver='17'
              fi

              local jdk_home=$(${java_home}/bin/java_home -v $ver)
              export JAVA_HOME=$jdk_home
              load_prefix "$JAVA_HOME"
              PATH_add "$JAVA_HOME/bin"
            }
          '';
        };
      };
      use_chruby = {
        enable = mkOption {
          default = false;
          description = "Whether to enable hte use of chruby in direnv";
        };
        script = mkOption {
          type = types.str;
          default = ''
            use_ruby() {
              # enable the chruby command in an environment
              source ${pkgs.chruby}/share/chruby/chruby.sh

              # desired Ruby version as first parameter
              local ver=$1

              # if version not given as parameter and there is a .ruby-version file, get
              # version from the file
              if [[ -z $ver ]] && [[ -f .ruby-version ]]; then
                ver=$(cat .ruby-version)
              fi

              # if the version still isn't set, error cause we don't know what to do
              if [[ -z $ver ]]; then
                echo Unknown ruby version
                exit 1
              fi

              # switch to the desired ruby version
              chruby $ver

              # Sets the GEM_HOME environment variable to `$PWD/.direnv/ruby/RUBY_VERSION`.
              # This forces the installation of any gems into the project’s sub-folder. If
              # you’re using bundler it will create wrapper programs that can be invoked
              # directly instead of using the `bundle exec` prefix.
              layout_ruby
            }
          '';
        };
      };
    };
  };

  config = mkIf (cfg.use_java.enable || cfg.use_chruby.enable) {
    programs.direnv.stdlib = mkDefault ''
      ${if cfg.use_java.enable then cfg.use_java.script else ""}
      ${if cfg.use_chruby.enable then cfg.use_chruby.script else ""}
    '';

    home.packages = if cfg.use_java.enable then [ java_home ] else [];
  };
}
