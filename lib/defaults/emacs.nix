{ pkgs, lib, ...}:

with lib;

let
  sourcesNix = import ../../nix/sources.nix;

  sources = {
    nur = import sourcesNix.nur { };
    emacs-overlay = import sourcesNix.emacs-overlay { };
  };

  pcfg = config.programs.emacs.init.usePackage;

in

{
  imports = [
    sources.nur.repos.rycee.hmModules.emacs-init
    sources.nur.repos.rycee.hmModules.emacs-notmuch
  ];

  programs = {
    emacs = {
      enable = mkDefault true;
      extraPackages = epkgs: with epkgs; [
        nix-mode
        magit
        projectile
      ];
    };
  };
}
