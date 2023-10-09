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
        16)
          JDK="${pkgs.openjdk16-bootstrap}"
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
    };
  };

  config = mkIf (cfg.use_java.enable) {
    programs.direnv.stdlib = mkDefault ''
      ${if cfg.use_java.enable then cfg.use_java.script else ""}
    '';

    home.packages = if cfg.use_java.enable then [ java_home ] else [];
  };
}
