{ lib, pkgs, ...}:

let

  #
  # CUSTOM GENERIC PACKAGES
  #
  future-git = pkgs.writeShellScriptBin "future-git" ''
    function help {
      echo "Usage: $0 <hours> [<git args>]"
      exit 1
    }

    if [ $# -eq 0 ]; then
      help
    fi

    items=( "$@" )
    (for e in "''${items[@]}"; do [[ "$e" =~ ^(--)?help$ ]] && exit 0; done; exit 1) && help

    HOURS=4
    re='^[0-9]+$'
    if [[ $1 =~ $re ]]; then
      HOURS=$1
      shift
    fi

    DATE="$(date -d +''${HOURS}hours)"
    GIT_AUTHOR_DATE="''${DATE}" GIT_COMMITTER_DATE="''${DATE}" git "$@"
  '';

  jqo = pkgs.writeShellScriptBin "jqo" ''
    ${pkgs.jq}/bin/jq -R -r 'capture("(?<prefix>[^{]*)(?<json>{.+})?(?<suffix>.*)") | .prefix,(.json|try fromjson catch ""),.suffix | select(length > 0)'
  '';

  markdown = pkgs.emem.overrideAttrs (oldAttrs: rec {
    installPhase = oldAttrs.installPhase + ''
      ln -fs $out/bin/emem $out/bin/markdown
    '';
  });

  nix-system = pkgs.writeShellScriptBin "nix-system" ''
    echo 'nix-shell -p nix-info --run "nix-info -m"'
    nix-shell -p nix-info --run "nix-info -m"
  '';

  nix-version = pkgs.writeShellScriptBin "nix-version" ''
    nix-instantiate --eval -A 'lib.version' '<nixpkgs>' | xargs
  '';

  #
  # CUSTOM DARWIN PACKAGES
  #

  app-path = pkgs.writeShellScriptBin "app-path" ''
    color()(set -o pipefail;"$@" 2>&1>&3|sed $'s,.*,\e[31m&\e[m,'>&2)3>&1
    echoerr() { echo "$@" 1>&2; }
    function indented() {
        (set -o pipefail; { "$@" 2>&3 | sed >&2 's/^/   | /'; } 3>&1 1>&2 | perl -pe 's/^(.*)$/\e[31m   | $1\e[0m/')
    }
    function join_by { local d=$1; shift; local f=$1; shift; printf %s "$f" "''${@/#/$d}"; }
    function usage {
      echo "Usage: app-path fuzzyname..."
      exit 1
    }
    [[ $# -lt 1 ]] && usage

    LOCATIONS=( "$HOME/.nix-profile/Applications" "$HOME/.nix-profile/Applications/Utilities" "$HOME/Applications" "$HOME/Applications/Utilities" "/Applications" "/Applications/Utilities" "/System/Applications" "/System/Applications/Utilities" )
    MATCHER=$(join_by '.*' "$@")

    APP=""
    for l in "''${LOCATIONS[@]}"; do
      if ! [ -d $l ]; then
        continue;
      fi
      NAME=$(ls "$l" | grep -i "$MATCHER")
      COUNT=$(echo "$NAME" | grep -v -e '^$' | wc -l)
      if [[  $COUNT -gt 1 ]]; then
        color echoerr "Matches:"
        indented echoerr "$NAME"
        usage
      fi
      if [[ $COUNT -eq 1 ]]; then
        APP="$l/$NAME"
        break
      fi
    done
    if [ -z "$APP" ]; then
      usage
    else
      echo "$APP"
    fi
  '';

  idownload = pkgs.writeShellScriptBin "idownload" ''
    if [ "$#" -ne 1 ] || ! [ -e $1 ]; then
        echo "Usage: idownload <file|dir>";
        return 1;
      fi
      find . -name '.*icloud' |\
      perl -pe 's|(.*)/.(.*).icloud|$1/$2|s' |\
      while read file; do brctl download "$file"; done
  '';

  nix-allow = pkgs.writeShellScriptBin "nix-allow" ''
    function usage {
      echo "Usage $(basename $0) fuzzyname"
      exit 1
    }

    [[ $# -lt 1 ]] && usage
    NAME=$1; shift
    APP=$(${app-path}/bin/app-path "$NAME")
    if [ -z "$APP" ]; then
      usage 1
    else
      realapp=$(realpath "$APP")
      codesign --force --deep --sign - "$realapp"
    fi
  '';

  nix-open = pkgs.writeShellScriptBin "nix-open" ''
    function usage {
      echo "Usage: nix-open application [args...]"
      exit 1
    }
    [[ $# -lt 1 ]] && usage
    NAME=$1; shift
    APP=$(${app-path}/bin/app-path "$NAME")
    if [ -z "$APP" ]; then
      usage
    else
      open -a "$APP" "$@"
    fi
  '';

  nix-reopen = pkgs.writeShellScriptBin "nix-reopen" ''
    function usage {
      echo "Usage: nix-reopen application [args...]"
      exit 1
    }
    [[ $# -lt 1 ]] && usage
    LOCATIONS=( "~/.nix-profile/Applications" "~/Applications" "/Applications" )
    NAME=$1
    APP=$(${app-path}/bin/app-path "$NAME")
    if [ -z "$APP" ]; then
      usage
    else
      PNAME=$(defaults read "$APP/Contents/Info" CFBundleExecutable)
      PIDSCOUNT=$(pgrep -i "$PNAME" | wc -l)
      if [[ $PIDSCOUNT -ne 0 ]]; then
        pkill -QUIT -i "$PNAME"
      fi
      ${nix-open}/bin/nix-open "$@"
    fi
  '';

  sudo-with-touch = pkgs.writeShellScriptBin "sudo-with-touch" ''
    primary=$(cat /etc/pam.d/sudo | head -2 | tail -1 | awk '{$1=$1}1' OFS=",")
    if [ "auth,sufficient,pam_tid.so" != "$primary" ]; then
      newsudo=$(mktemp)
      awk 'NR==2{print "auth       sufficient     pam_tid.so"}7' /etc/pam.d/sudo > $newsudo
      sudo mv $newsudo /etc/pam.d/sudo
    fi
  '';

in
{
  home.packages = [
    future-git
    jqo
    markdown
    nix-system
    nix-version
  ]
  ++ lib.optionals pkgs.stdenv.isDarwin ([
    app-path
    idownload
    nix-allow
    nix-open
    nix-reopen
    sudo-with-touch
  ]);
}
