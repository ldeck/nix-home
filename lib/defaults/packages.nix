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
      aspellDicts.en
      bc
      clang_13
      coreutils
      coreutils-prefixed
      editorconfig-core-c
      fd
      ffmpeg
      gdb
      gnupg
      jq
      jsonnet
      nox
      perl
      ripgrep
      silver-searcher
      sqls
      #taskwarrior
      (symlinkJoin {
        inherit (taskwarrior) name meta;
        paths = [taskwarrior];
        postBuild = ''
          mv $out/bin/task $out/bin/tw
          mv $out/share/zsh/site-functions/_task $out/share/zsh/site-functions/_tw
          mv $out/share/bash-completion/completions/task.bash $out/share/bash-completion/completions/tw.bash
          mv $out/share/fish/vendor_completions.d/task.fish $out/share/fish/vendor_completions.d/tw.fish
        '';
      })
      tree
      python310Packages.yamllint
      zlib
    ];
  };
}
