{ pkgs, ...}:

{
  programs = {
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
        ".project"
        ".settings"
        "*~"
        "*.swp"
      ];
      extraConfig = {
        core.quotepath = true;
        merge.conflictstyle = "diff3";
        pull.rebase = true;
        status.showUntrackedFiles = "all";
      };
    };
  };
}
