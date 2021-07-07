{ pkgs, ... }:

let

  # ---------------------------------------------------------
  # FUNCTIONS
  # ---------------------------------------------------------

  tryGetAttr = key: set: msg:
     if builtins.hasAttr key set
     then builtins.getAttr key set
     else throw msg;

  tryImport = path:
    if builtins.pathExists path
    then import path
    else throw "${path} does not exist";

  # ---------------------------------------------------------
  # VARIABLES
  # ---------------------------------------------------------

  homedir = builtins.getEnv "HOME";
  username = builtins.getEnv "USER";

  __gitpath = "${homedir}/.me.d/git.nix";
  __gitinfo = tryImport __gitpath;

  fullname = tryGetAttr "name" __gitinfo ''${__gitpath} missing attribute 'name'. e.g., name = "Lachlan Deck";'';
  email = tryGetAttr "email" __gitinfo "${__gitpath} missing attribute 'email'.";

in
{

  # The home-manager manual is at:
  #
  #   https://rycee.gitlab.io/home-manager/release-notes.html
  #
  # Configuration options are documented at:
  #
  #   https://rycee.gitlab.io/home-manager/options.html

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  #
  # You need to change these to match your username and home directory
  # path:
  home.username = username;
  home.homeDirectory = homedir;

  # If you use non-standard XDG locations, set these options to the
  # appropriate paths:
  #
  # xdg.cacheHome
  # xdg.configHome
  # xdg.dataHome

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "20.09";

  # ----------------------------------------------------------------
  # programs
  # ----------------------------------------------------------------
  programs.autojump.enable = true;

  # Since we do not install home-manager, you need to let home-manager
  # manage your shell, otherwise it will not be able to add its hooks
  # to your profile.
  programs.bash.enable = true;
  programs.direnv.enable = true;

  programs.emacs = {
    enable = true;
    extraPackages = epkgs: with epkgs; [
      nix-mode
      magit
    ];
  };

  programs.git = {
    enable = true;
    userName = fullname;
    userEmail = email;
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
    ignores = [ "*~" "__pycache__" "*.pyc" "*.swp" ".*-cache" "build/" ];
    extraConfig = {
      merge.conflictstyle = "diff3";
      pull.rebase = true;
      core.quotepath = true;
    };
  };

  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
  };

  home.packages = with pkgs; [
    # example packages
    htop
    fortune

    # vcs
    git

    # nix basics
    niv
    nixfmt
    nix-prefetch-github
    nix-prefetch-scripts
    undmg
    styx
  ];

}
