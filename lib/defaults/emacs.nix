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
  };
}
