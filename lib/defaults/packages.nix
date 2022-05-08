{ lib, pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      # EXAMPLES
      htop
      fortune

      # NIX BASICS
      niv
      nixfmt
      nix-prefetch-github
      nix-prefetch-scripts
      undmg

      # TOOLS
      aspell
      bc
      clang_13
      coreutils
      fd
      ffmpeg
      gdb
      gnupg
      jq
      nox
      perl
      ripgrep
      silver-searcher
      taskwarrior
      tree
      python38Packages.yamllint
    ];
  };
}
