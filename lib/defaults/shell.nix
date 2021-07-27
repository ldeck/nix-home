{ pkgs, ...}:
let

  essentialShellAliases = {
    e = "emacs -nw";
    ec = "emacsclient -nw -c";

    recd = "cd / && cd -";

    ll = "ls -lAFG";
    l = "ls -laFG";
  };

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
      shellAliases = essentialShellAliases // { reload = "exec bash"; };
    };
    zsh = {
      enable = true;
      shellAliases = essentialShellAliases // { reload = "exec zsh"; };
    };
  };
}
