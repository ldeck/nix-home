{ pkgs, lib, ... }:
with lib;
{
  programs.direnv.enable = mkOverride 100 true;
  programs.direnv.use_java.enable = mkOverride 100 true;
}
