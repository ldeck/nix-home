{ pkgs, ...}:
let

  essentialShellAliases = {
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
  programs = {
    autojump = {
      enable = true;
    };

    # Since we do not install home-manager, you need to let home-manager
    # manage your shell, otherwise it will not be able to add its hooks
    # to your profile.

    bash = {
      enable = true;
      shellAliases = essentialShellAliases // {
        reload = "unset __HM_SESS_VARS_SOURCED && exec bash";
      };
      initExtra = shellFunctions;
    };
    zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableSyntaxHighlighting = true;
      shellAliases = essentialShellAliases // {
        reload = "unset __HM_SESS_VARS_SOURCED && exec zsh";
      };
      # Fix zsh for macos: https://gist.github.com/Linerre/f11ad4a6a934dcf01ee8415c9457e7b2
      loginExtra = ''
        [ -r $HOME/.zshenv ] && . $HOME/.zshenv
      '';
      initExtra = ''
        # autocompletion using arrow keys (based on history)
        bindkey '\e[A' history-search-backward
        bindkey '\e[B' history-search-forward

        # https://superuser.com/questions/446594/separate-up-arrow-lookback-for-local-and-global-zsh-history

        function up-line-or-history() {
          zle set-local-history 1
          zle .up-line-or-history
          zle set-local-history 0
        }

        function down-line-or-history() {
          zle set-local-history 1
          zle .down-line-or-history
          zle set-local-history 0
        }

        # Overwrite existing {up,down}-line-or-history widgets with the functions above.
        zle -N up-line-or-history
        zle -N down-line-or-history

        ${shellFunctions}
      '';
    };
  };
}
