{ pkgs, lib, ...}:

with lib;

{
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
