{ pkgs, lib, ... }:
with lib;
{
  programs.direnv.enable = mkOverride 100 true;
  programs.direnv.enableBashIntegration = mkOverride 100 true;
  programs.direnv.enableZshIntegration = mkOverride 100 true;
  programs.direnv.use_java.enable = mkOverride 100 true;
  programs.direnv.nix-direnv.enable = mkOverride 100 true;
  programs.direnv.stdlib = mkBefore ''
    export DIRENV_WARN_TIMEOUT=10s
    # export NIX_DIR_ENV_CACHE=0
    # export NIX_DIRENV_DISABLE_CACHE=1

    LIB=$HOME/.config/direnv/lib
    if [ -d "$LIB" ]; then
      for f in "$LIB/*.sh"; do
        [ -f "$f" ] && source "$f"
      done
    fi

    if [ -f "$HOME/.nix-profile/share/nix-direnv/direnvrc" ]; then
       source "$HOME/.nix-profile/share/nix-direnv/direnvrc"
    fi
  '';
}
