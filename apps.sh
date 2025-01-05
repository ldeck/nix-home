#!/usr/bin/env bash

# See https://stackoverflow.com/a/246128/3561275
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"



for dd in `ls $DIR/lib/defaults/apps/macOS/ | grep -E "^[0-9a-z].*.nix"`; do
    name="${dd%.*}"
    if [ "chromium" = "$name" ]; then
        $DIR/bin/nix-chromium $DIR/lib/defaults/apps/macOS/$dd
    else
        $DIR/bin/nix-middy "$name" $DIR/lib/defaults/apps/macOS/$dd
    fi
    echo $dd
done
