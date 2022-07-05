NIXSHELL=init.nix

function usage {
  echo "Usage: $(basename $0) [-h|--help | args...]"
  exit $1
}

if [[ "$#" -eq 0 ]]; then
  usage 1
fi

nix-shell --run "niv $@" $NIXSHELL
