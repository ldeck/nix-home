{ pkgs, lib, ...}:
let

  essentialShellAliases = {
    bash-noprofile = "bash --noprofile";
    zsh-noprofile = "zsh -d -f -i";

    e = "emacs -nw";
    ec = "emacsclient -nw -c";

    recd = "cd / && cd -";

    ll = "ls -lAFG";
    l = "ls -laFG";
  };

  shellFunctions = ''
    function cdmkdir() {
      if [[ $# -ne 1 ]]; then
        echo "Usage: cdmkdir <dir>"
        exit 1
      fi
      mkdir -p $1
      cd $1
    }
  '';

in
{
  home.packages = [
    pkgs.bash
  ];

  home.sessionVariables = {
    LIBRARY_PATH = ''${lib.makeLibraryPath [pkgs.libiconv]}''${LIBRARY_PATH:+:$LIBRARY_PATH}'';
  };

  programs = {
    autojump = {
      enable = true;
    };

    # Since we do not install home-manager, you need to let home-manager
    # manage your shell, otherwise it will not be able to add its hooks
    # to your profile.

    bash = {
      enable = lib.mkOverride 100 true;
      shellAliases = essentialShellAliases // {
        reload = "unset __HM_SESS_VARS_SOURCED && exec bash";
      };
      initExtra = shellFunctions;
    };
    zsh = {
      enable = true;
      enableAutosuggestions = true;
      syntaxHighlighting.enable = true;
      shellAliases = essentialShellAliases // {
        reload = "unset __HM_SESS_VARS_SOURCED && exec zsh";
      };
      # Fix zsh for macos: https://gist.github.com/Linerre/f11ad4a6a934dcf01ee8415c9457e7b2
      loginExtra = ''
        [ -r $HOME/.zshenv ] && . $HOME/.zshenv
      '';
      initExtra = ''
        autoload -U up-line-or-beginning-search
        autoload -U down-line-or-beginning-search
        zle -N up-line-or-beginning-search
        zle -N down-line-or-beginning-search
        bindkey '\e[A' up-line-or-beginning-search
        bindkey '\e[B' down-line-or-beginning-search

        ${shellFunctions}
      '';
    };
  };
}
