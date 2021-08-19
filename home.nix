{ pkgs, lib, ... }:

let

  # ---------------------------------------------------------
  # ENVIRONMENT
  # ---------------------------------------------------------

  homeDir = builtins.getEnv "HOME";
  userName = builtins.getEnv "USER";

  libDir = ./lib/defaults;
  meDir = "${homeDir}/.me.d";

  # ---------------------------------------------------------
  # FUNCTIONS
  # ---------------------------------------------------------

  nixFilesIn = dir: with builtins;
    map
      (f: "${dir}/${f}")
      (filter
        (f: lib.strings.hasSuffix ".nix" "${f}")
        (builtins.attrNames (builtins.readDir dir)));

  # ---------------------------------------------------------
  # VARIABLES
  # ---------------------------------------------------------

  modules = []
    ++ nixFilesIn libDir
    ++ nixFilesIn meDir;

in
{
  imports = modules;

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "openssl-1.0.2u"
    ];
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  #stateVersion = "20.09";
  home.stateVersion = "20.09";
}
