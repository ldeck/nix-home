{ pkgs, ... }:

let

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

    defaultPath = name: "${env.baseDir}/defaults}/${name}.nix";
    mePath = name: "${env.meDir}/${name}.nix";

    optCallPackage = package: args: default:
      if builtins.pathExists package
      then pkgs.callPackage package args
      else default;
  };


  # ---------------------------------------------------------
  # VARIABLES
  # ---------------------------------------------------------

  functionArgs = {
    pkgs = pkgs;
    env = env;
    helpers = helpers;
  };

  defaultHome = with helpers; optCallPackage (defaultPath "home") functionArgs {};
  defaultPrograms = with helpers; optCallPackage (defaultPath "programs")  functionArgs {};

  customHomeArgs = { defaults = defaultHome; } // functionArgs;
  customHome = with helpers; optCallPackage (mePath "home") customHomeArgs {};

  customProgramsArgs = { defaults = defaultPrograms; } // functionArgs;
  customPrograms = with helpers; optCallPackage (mePath "programs") customProgramsArgs {};

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
  home = defaultHome // customHome // { stateVersion = "20.09"; };

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

  programs = defaultPrograms // customPrograms;

}
