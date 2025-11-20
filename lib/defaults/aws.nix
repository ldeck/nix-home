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

      completions = mkOption {
        type = lib.types.str;
        default = ''
          complete -C aws_completer aws
        '';
        description = "Shell completions for aws cli";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      awscli2
      saml2aws
      ssm-session-manager-plugin
    ];

    programs.zsh.initContent = lib.mkAfter cfg.completions;
    programs.bash.bashrcExtra = lib.mkAfter cfg.completions;
  };
}
