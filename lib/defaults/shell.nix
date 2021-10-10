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
      initExtra = shellFunctions;
    };
  };
}
