# home-manager team template

This provides a quick-start template for using
[home-manager](https://github.com/rycee/home-manager) in a more
reproducible way for multiple team members.

NB: You don't have to install home-manager, and it uses pinning.

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

```sh
curl -L https://nixos.org/nix/install | sh
```

# Setup

1. Click the "Use this template" or "Code" button on GitHub
1. Clone your repository onto the computer you want to configure
1. Initialise pinned dependencies (home-manager and nixpkgs) with the latest version:

   ```sh
   ./update-dependencies --init
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
   ./update-dependencies.sh
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
    ./switch.sh
    ```

    which is just shorthand for:

    ```
    nix-shell --run "home-manager switch"
    ```

# Home configuration

This home-manager configuration is intended as a baseline for shared configurations for a team.

## Defaults ##

The 'default' configuration provided by this configuration is in [home.nix](home.nix)
which imports all modules from [lib/defaults](lib/defaults).

## Required ##

At a minimum you should configure git with your userName and userEmail.

Example `~/.me.d/git.nix` module:

    {}:
    {
      programs.git.userEmail = "your.email@example.com";
      programs.git.userName = "Your Name";
    }

## Personalisation ##

All personalised configuration is loaded from all your `~/.me.d/*.nix` files. You can
split out your personalised configuration in any .nix files you like in that directory.

### macOS apps ###

A list of macOS desktop apps are available to enable in [lib/defaults/apps/macOS](lib/defaults/apps/macOS).

An example of enabling or customising one:

    #~/.me.d/apps.nix
    {}:
    {
      macOS.apps.authy.enable = true;
    }

Other customisable options are available for the version and sha256, should you wish to manage the version updates separately.

# Caveats

Since we do not install home-manager, you need to let home-manager
manage your shell, otherwise it will not be able to add its hooks to
your profile, e.g. no shell variables will get set by home-manager.
Please consult home-manager documentation for exact required steps.

Also since we do not install home-manager, you cannot run the
home-manager script from any directory and expect it to work. It must
be run from within the nix-shell. (This is actually a feature!)
