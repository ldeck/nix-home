{ lib, pkgs, ... }:

{
  home = {
    packages = with pkgs; [
      # EXAMPLES
      htop
      fortune

      # NIX BASICS
      niv
      nixfmt-classic
      nix-prefetch-github
      nix-prefetch-scripts
      undmg

      # TOOLS
      aider-chat # AI pair programming in your terminal
      aspell
      aspellDicts.en
      bat
      bc
      clang_13
      #coreutils
      coreutils-prefixed
      croc
      dsq
      duckdb
      editorconfig-core-c
      fd
      ffmpeg
      gdb
      gnumake
      gnupg
      (google-cloud-sdk.withExtraComponents [google-cloud-sdk.components.gke-gcloud-auth-plugin])
      httpie
      #iconv
      jq
      jsonnet
      k9s
      lazygit
      libiconv
      lnav
      nox
      nushell
      perl
      ripgrep
      rustup
      semgrep # used by lsp
      silver-searcher
      sqls
      #taskwarrior
      (symlinkJoin {
        inherit (taskwarrior3) name meta;
        paths = [taskwarrior3];
        postBuild = ''
          mv $out/bin/task $out/bin/tw
          mv $out/share/zsh/site-functions/_task $out/share/zsh/site-functions/_tw
          mv $out/share/bash-completion/completions/task.bash $out/share/bash-completion/completions/tw.bash
          mv $out/share/fish/vendor_completions.d/task.fish $out/share/fish/vendor_completions.d/tw.fish
        '';
      })
      tree
      python310Packages.yamllint
      xq-xml
      zlib
    ];
  };
}
