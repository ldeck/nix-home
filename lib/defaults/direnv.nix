{ pkgs, ... }:

let

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
  programs.direnv = {
    enable = true;
    stdlib = ''
      use_java() {
        JAVA_HOME=$(${java_home}/bin/java_home -v $1)
        export JAVA_HOME="$JAVA_HOME"
        echo "JAVA_HOME=$JAVA_HOME"
        load_prefix "$JAVA_HOME"
        PATH_add "$JAVA_HOME/bin"
      }
    '';
  };

  home.packages = [ java_home ];
}
