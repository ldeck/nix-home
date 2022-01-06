{ pkgs, lib, ... }:

let

  # ---------------------------------------------------------
  # ENVIRONMENT
  # ---------------------------------------------------------

  homeDir = builtins.getEnv "HOME";
  userName = builtins.getEnv "USER";

  libDir = toString ./lib/defaults;

  meConfig = "${homeDir}/.me.nix";
  defaultMeDir = "${homeDir}/.me.d";

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

  libModules = nixFilesIn libDir;

  meModules =
    with builtins;
    if pathExists meConfig then
      concatMap (p: nixFilesIn p)(import meConfig)
    else
      if pathExists defaultMeDir then
        nixFilesIn defaultMeDir
      else
        [];

  modules = libModules ++ meModules;

in
{
  imports = modules;

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [];
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
