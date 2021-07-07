NIXSHELL=shell.nix

function usage {
  echo "Usage: $(basename $0) [-h|--help] [-i|--init]"
  exit $1
}

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -h|--help) usage 0;;
    -i|--init)
       NIXSHELL=init.nix
    *) usage 1;;
  esac
  shift
done

nix-shell --run "niv update" $NIXSHELL
