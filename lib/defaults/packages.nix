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
      styx

      # TOOLS
      aspell
      bc
      clang
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

      # CLOUD
      awscli2
    ];
  };
}
