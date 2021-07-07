{ pkgs, ... }:

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
  home.username = "ldeck";
  home.homeDirectory = "/Users/ldeck";

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

  # Since we do not install home-manager, you need to let home-manager
  # manage your shell, otherwise it will not be able to add its hooks
  # to your profile.
  programs.bash = {
    enable = true;
  };

  programs.emacs = {
    enable = true;
    extraPackages = epkgs: with epkgs; [
      nix-mode
      magit
    ];
  };

  programs.git = {
    enable = true;
    userName = "Lachlan Deck";
    userEmail = "lachlan.deck@gmail.com";
    aliases = {
      st = "status";
    };
  };

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
