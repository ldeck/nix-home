# nix home-manager team template

This provides a quick-start template for using
[home-manager](https://github.com/rycee/home-manager)'s
[IaC](https://en.wikipedia.org/wiki/Infrastructure_as_code "wikipedia: Infrastructure as Code")
atop of the [nix](https://nixos.org) package manager
in a more reproducible way for multiple team members.

Reproducibility across systems is achieved by using pinned nix packages. This team template uses [niv](https://github.com/nmattia/niv) to do so.


# Why?

home-manager is a great way to manage user-specific configuration
("dotfiles") in a reproducible way. This template takes
reproducibility another step by making it so you do not need to
install home-manager to use it, and do not need to install
home-manager configuration files in a specific place.

Also, since this uses niv to pin nixpkgs and home-manager, you do not
need nixpkgs on your path and can be sure the build will be the same
on any computer.

# Prerequisites

You must have [nix](https://nixos.org) installed on your machine.

NB: You do not need to install [home-manager](https://github.com/rycee/home-manager) itself. It is supplied via a nix shell when running the below scripts.

# Setup

1. Click the "Use this template" or "Code" button on GitHub
1. Clone your repository onto the computer you want to configure
1. Initialise pinned dependencies (home-manager and nixpkgs) with the latest version:

   ```sh
   ./dependencies.sh --init
   ```

   which is just shorthand for:

   ```sh
   nix-shell --run "niv update" init.nix
   ```

NB: this last setup step was crucial on macOS 11.x Big Sur as otherwise shell.nix
can load a version of nixpkgs that suffers from clang errors.

# Usage

1. Optionally update dependencies (home-manager and nixpkgs) to the latest version:

   ```sh
   ./dependencies.sh --update
   ```

   which is just shorthand for:

   ```
   nix-shell --run "niv update" [shell.nix]
   ```
2. Optionally stay informed about home-manager news:

   ```sh
   ./news.sh
   ```

   which is just shorthand for:

   ```sh
   nix-shell --run "home-manager news" [shell.nix]
   ```

3. Edit your [home configuration](#home-configuration) to be how you want it.
4. Run the switch script to switch to your configuration:

    ```sh
    ./switch.sh [-h|--help] [--show-trace] [...]
    ```

    which, apart from `[-h|--help]` which echos script options, is just shorthand for:

    ```
    nix-shell --run "home-manager switch [--show-trace] [...]"
    ```
5. List installed packages:

    ```sh
    ./dependencies.sh --list
    ```

    which is just shorthand for:

    ```sh
    nix-shell --run "home-manager packages"
    ```

# Home configuration

This home-manager configuration is intended as a baseline for shared configurations for a team.

See both the [home-manager](https://github.com/rycee/home-manager) documentation and the following for additional options specific to this configuration.

## Defaults ##

The 'default' configuration provided by this configuration is in [home.nix](home.nix)
which imports all modules from [lib/defaults](lib/defaults).

These include:
- [lib/defaults/apps.nix](lib/defaults/apps.nix)
- [lib/defaults/aws.nix](lib/defaults/aws.nix)
- [lib/defaults/direnv.nix](lib/defaults/direnv.nix)
- [lib/defaults/emacs.nix](lib/defaults/emacs.nix)
- [lib/defaults/git.nix](lib/defaults/git.nix)
- [lib/defaults/packages.nix](lib/defaults/packages.nix)
- [lib/defaults/scripts.nix](lib/defaults/scripts.nix)
- [lib/defaults/shell.nix](lib/defaults/shell.nix)
- [lib/defaults/user.nix](lib/defaults/user.nix)
- [lib/defaults/utils.nix](lib/defaults/utils.nix)

## Required ##

At a minimum you should configure git with your userName and userEmail.

Example `~/.me.d/git.nix` module:

    {...}:
    {
      programs.git.userEmail = "your.email@example.com";
      programs.git.userName = "Your Name";
    }

## Personalisation ##

All personalised configuration is loaded from all your `~/.me.d/*.nix` files. You can
split out your personalised configuration in any .nix files you like in that directory or use a monolithic nix file. It's your choice.

NB: to configure multiple personalisation dirs (e.g., a personal one and a corporate one), define the following file:

    #~/.me.nix
    [
      "~/.me.d"
      "~/.foobar-corp.d"
    ]

### kryptco.kr (ssh integration) ###

See https://krypt.co

To enable version 2.4.15:

    #~/.me.d/utils.nix
    {...}:
    {
      utils.security.kryptco.kr.enable = true;
    }

### macOS apps ###

A list of macOS desktop apps are available to enable in [lib/defaults/apps/macOS](lib/defaults/apps/macOS).

#### Enabling Apps ####

An example of enabling or customising one:

    #~/.me.d/apps.nix
    {...}:
    {
      macOS.apps = {
        authy.enable = true;
        docker.enable = true;
        firefox.enable = true;
      };
    }

Other customisable options are available for the version and sha256, should you wish to manage the version updates separately.

#### Spotlight Integration ####

To ensure the apps installed via nix are seen by spotlight, you can enable the following flag which will by default add aliases for the apps into ~/Applications/Nix.

    #~/.me.d/apps.nix
    {...}:
    {
      ...
      macOS.apps = {
        aliases.enable = true;
      };
    }

NB: see https://github.com/nix-community/home-manager/issues/1341#issuecomment-901513436 for further discussion and details.

#### AWS ####

Enabling the inclusion of awscli can be done in two ways:

    #~/.me.d/aws.nix
    {...}:
    {
      cloud.aws.enable = true;
    }

Which at this time is equivalent to:

    #~/.me.d/programs.nix
    {pkgs, ...}:
    {
      home.packages = with pkgs; [
        awscli2
      ];
    }

# Caveats

Since we do not install home-manager, you need to let home-manager
manage your shell, otherwise it will not be able to add its hooks to
your profile, e.g. no shell variables will get set by home-manager.
Please consult home-manager documentation for exact required steps.

Also since we do not install home-manager, you cannot run the
home-manager script from any directory and expect it to work. It must
be run from within the nix-shell. (This is actually a feature!)
