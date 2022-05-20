{ pkgs, lib, config, ... }:

with lib;
with attrsets;

let
  cfg = config.programs.ruby;

  mkRubyLoc = dir: r: "${dir}/ruby-${r.version}";
  mkRubySrc = dir: r: {
    source = r;
    target = mkRubyLoc dir r;
  };

  mkRubyFile = dir: r: {
    home.file."${mkRubyLoc dir r}" = mkRubySrc dir r;
  };

  mkRubies = dir: list: map (r: mkRubyFile dir r) list;

  defaultRubies = with pkgs; [ ruby_2_7 ruby_3_0 ruby_3_1 ];

in
{
  options = {
    programs.ruby = {
      enable = mkEnableOption "A pseudo ruby-install module.";

      /* fixme: this causes an infinite recursion when referenced! */
      list = mkOption {
        type = types.listOf types.package;
        default = [];
        description = "The set of ruby packages to appear in the user environment.";
      };

      path = mkOption {
        type = types.str;
        default = ".rubies";
        description = "The user directory to install the rubies into.";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge (mkRubies cfg.path defaultRubies));
}
