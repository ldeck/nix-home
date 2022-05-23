{ pkgs, lib, config, ... }:

with lib;
with attrsets;

let
  cfg = config.programs.ruby;

  mkRubyAttrSet = dir: list:
    let
      mkName = r: "${dir}/ruby-${r.version}";
      mkSetsList = map (r: nameValuePair (mkName r) r) list;
    in
      listToAttrs (mkSetsList);

  defaultRubies = lib.filterAttrs (k: _: lib.strings.hasPrefix "ruby_" k) pkgs;

in
{
  options = {
    programs.ruby = {
      enable = mkEnableOption "A pseudo ruby-install module.";

      packages = mkOption {
        type = types.listOf types.package;
        default = builtins.attrValues defaultRubies;
        defaultText = "[ ${lib.concatStringsSep " " (builtins.map (r: "pkgs.${r}") (builtins.attrNames defaultRubies)) } ]";
        example = "[ pkgs.ruby_3_0 pkgs.ruby_3_1 ]";
        description = ''
          The set of ruby packages to appear in the user environment.

          To discover what versions of ruby are available in your current version of nixpkgs:

          ```
          nix-instantiate --eval -E 'with import <nixpkgs> {}; __filter (lib.hasPrefix "ruby_") (__attrNames pkgs)'
          // or
          nix eval --impure --expr 'with import <nixpkgs> {}; __filter (lib.hasPrefix "ruby_") (__attrNames pkgs)'
          ````

          Helpful references for older ruby versions:
          - https://lazamar.co.uk/nix-versions/?channel=nixpkgs-unstable&package=ruby
          - https://til.codes/using-custom-versions-of-libraries-and-packages-using-nix/
        '';
      };

      path = mkOption {
        type = types.str;
        default = ".rubies";
        defaultText = ".rubies";
        example = ".rbenv/versions";
        description = "The user directory to install the rubies into.";
      };
    };
  };

  config = mkIf cfg.enable {
    home.file = mapAttrs (name: r: {
      source = r;
      target = name;
    }) (mkRubyAttrSet cfg.path cfg.packages);
  };
}
