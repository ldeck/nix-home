{ pkgs, lib, ... }:
with lib;
{
  programs.direnv.enable = mkOverride 100 true;
  programs.direnv.use_java.enable = mkOverride 100 true;
  programs.direnv.nix-direnv.enable = mkOverride 100 true;
  programs.direnv.stdlib = mkBefore ''
    if [ -f "$HOME/.nix-profile/share/nix-direnv/direnvrc" ]; then
       source "$HOME/.nix-profile/share/nix-direnv/direnvrc"
    fi
  '';
}
