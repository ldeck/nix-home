NIXSHELL=shell.nix

function usage {
  echo "Usage: $(basename $0) [-h|--help] [-i|--init] [-l|--list] [-u|--update]"
  exit $1
}

if [[ "$#" -gt 0 ]]; then
  CMD="niv update"
  OP=$1
  shift

  case "$OP" in
    -h|--help) usage 0;;
    -i|--init) NIXSHELL=init.nix;;
    -l|--list) CMD="home-manager packages";;
    -u|--update) ;;
    *) usage 1;;
  esac
else
    usage 0
fi

nix-shell --run "$CMD $@" $NIXSHELL
