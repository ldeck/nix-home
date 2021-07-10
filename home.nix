{ pkgs, lib, ... }:

let
  debugCallPackage = false;

  # ---------------------------------------------------------
  # ENV
  # ---------------------------------------------------------

  env = rec {
    homedir = builtins.getEnv "HOME";
    username = builtins.getEnv "USER";
    baseDir = "${toString ./.}";
    meDir = "${homedir}/.me.d";
  };

  # ---------------------------------------------------------
  # FUNCTIONS
  # ---------------------------------------------------------

  helpers = rec {
    tryGetAttr = key: set: msg:
     if builtins.hasAttr key set
     then builtins.getAttr key set
     else throw msg;

    optImport = path: default:
      if builtins.pathExists path
      then import path
      else default;

    tryImport = path:
      if builtins.pathExists path
      then import path
      else throw "${path} does not exist";

    defaultPath = name: "${env.baseDir}/lib/defaults/${name}.nix";
    mePath = name: "${env.meDir}/${name}.nix";

    optCallPackage = package: args: default:
      if builtins.pathExists package
      then (if debugCallPackage
            then pkgs.callPackage package args
            else import package args)
      else default;
  };


  # ---------------------------------------------------------
  # VARIABLES
  # ---------------------------------------------------------

  functionArgs = {
    env = env;
    helpers = helpers;
  } // (if !debugCallPackage then {
    pkgs = pkgs;
    lib = lib;
  } else {});

  mkFunctionArgs = args:
    functionArgs // { defaults = args; };

in

 with helpers;
 let

   defaultHome = optCallPackage (defaultPath "home") functionArgs {};
   customHome = optCallPackage (mePath "home") (mkFunctionArgs defaultHome) {};

   defaultPrograms = optCallPackage (defaultPath "programs")  functionArgs {};
   customPrograms = optCallPackage (mePath "programs") (mkFunctionArgs defaultPrograms) {};

   homeManagement = defaultHome // customHome // { stateVersion = "20.09"; };
   programsManagement = defaultPrograms // customPrograms;

 in
{
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home = homeManagement;

  # If you use non-standard XDG locations, set these options to the
  # appropriate paths:
  #
  # xdg.cacheHome
  # xdg.configHome
  # xdg.dataHome

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

  programs = programsManagement;

}
