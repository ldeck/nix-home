{ pkgs, env, helpers, ...}:

let
  shellAliases = {};

in
{
  autojump = {
    enable = true;
  };

  # Since we do not install home-manager, you need to let home-manager
  # manage your shell, otherwise it will not be able to add its hooks
  # to your profile.
  bash = {
    enable = true;
    shellAliases = shellAliases;
  };

  direnv = {
    enable = true;
  };

  emacs = {
    enable = true;
    extraPackages = epkgs: with epkgs; [
      nix-mode
      magit
    ];
  };

  git = {
    enable = true;
    aliases = {
      unstage = "reset HEAD --";
      pr = "pull --rebase";
      co = "checkout";
      ci = "commit";
      c = "commit";
      b = "branch";
      p = "push";
      d = "diff";
      a = "add";
      s = "status";
      f = "fetch";
      br = "branch";
      lr = "reflog";
      l = "log --graph --pretty='%Cred%h%Creset - %C(bold blue)<%an>%Creset %s%C(yellow)%d%Creset %Cgreen(%cr)' --abbrev-commit --date=relative";
      hist = "log --branches --remotes --decorate --graph --pretty=format:'%C(auto) %>|(15) %h %d %<|(30trunc) %s %>|(100)%C(cyan)%ci %C(yellow)%an %C(cyan)(%ar)'";
      h = "hist";
    };
    ignores = [
      ".DS_Store"
      ".com.apple.backupd*"
      "*~"
      "*.swp"
    ];
    extraConfig = {
      core.quotepath = true;
      merge.conflictstyle = "diff3";
      pull.rebase = true;
    };
  };

  zsh = {
    enable = true;
    shellAliases = shellAliases;
  };
}
