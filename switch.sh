#!/bin/sh

usage() {
  echo "Usage: $(basename $0) [-h|--help]"
  echo "Usage: $(basename $0) [--show-trace] ..."
  exit $1
}

for arg in "$@"
do
  case "$arg" in
    -h|--help)
      usage 0
      ;;
    *)
      ;;
  esac
done

ARGS=""
if [ $# -gt 0 ]; then
  ARGS=" $@"
fi

set -x

nix-shell --run "home-manager switch$ARGS"
