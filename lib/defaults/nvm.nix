{ pkgs, lib, config, ... }:

with lib;

let
  cfg = config.programs.nvm;

  nvm =
    version:
    sha256:
    pkgs.stdenv.mkDerivation rec {
      name = "nvm-${version}";
      inherit version;
      src = pkgs.fetchFromGitHub {
        owner = "nvm-sh";
        repo = "nvm";
        rev = "v${version}";
        inherit sha256;
      };
      phases = [ "unpackPhase" "installPhase" ];

      installPhase = ''
        mkdir -p $out/share/nvm;
        cp nvm.sh $out/share/nvm/nvm.sh;
      '';
  };

in

{
  options = {
    programs.nvm = {
      enable = mkEnableOption "Whether to enable nvm installation";
      version = mkOption {
        default = "0.39.1";
        description = "The tagged version of nvm (without preceeding 'v')";
      };
      sha256 = mkOption {
        default = "jqjSKzSYiNY4+4xd2sS809OBfWwJB9GAuUHbC9MmvHQ=";
        description = "The sha256 for the given version";
      };

      zsh.enable = mkEnableOption "Whether to enable zsh integration";
      bash.enable = mkEnableOption "Whether to enable zsh integration";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = [
        (nvm cfg.version cfg.sha256)
      ];
    }

    (mkIf cfg.zsh.enable {
      programs.zsh.initExtra = ''
        mkdir -p $HOME/.nvm
        export NVM_DIR=$HOME/.nvm
        source $HOME/.nix-profile/share/nvm/nvm.sh;
      '';
    })

    (mkIf cfg.bash.enable {
      programs.bash.initExtra = ''
        mkdir -p $HOME.nvm
        export NVM_DIR="$HOME/.nvm"
        source $HOME/.nix-profile/share/nvm/nvm.sh;
      '';
    })
  ]);
}
