{ pkgs, lib, ... }:
{
  programs.direnv.enable = true;
  programs.direnv.use_java.enable = true;
}
