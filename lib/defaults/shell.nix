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
  programs.bash.shellAliases = essentialShellAliases // { reload = "exec bash"; };
  programs.zsh.shellAliases = essentialShellAliases // { reload = "exec zsh"; };
}
