{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.cloud.aws;
in {
  options = {
    cloud.aws = {
      enable = mkOption {
        default = false;
        description = "Whether to enable aws integration";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      awscli2
    ];
  };
}
