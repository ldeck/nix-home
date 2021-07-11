{ lib, pkgs, ... }:

let
  homeDir = builtins.getEnv "HOME";
  userName = builtins.getEnv "USER";

in
{
  home = {
    homeDirectory = homeDir;
    username = userName;
  };
}
