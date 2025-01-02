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

  initExtra = ''
    mkdir -p $HOME/.nvm
    export NVM_DIR=$HOME/.nvm
    export NODE_VERSIONS=$NVM_DIR/versions/node
    export NODE_VERSION_PREFIX=v
    source $HOME/.nix-profile/share/nvm/nvm.sh;
  '';


in

{
  options = {
    programs.nvm = {
      enable = mkEnableOption "Whether to enable nvm installation";
      version = mkOption {
        default = "0.39.5";
        description = "The tagged version of nvm (without preceeding 'v')";
      };
      sha256 = mkOption {
        default = "tUH6V+1HzLy0GT1Lk53p267/+MjARLmsGnfIHKWLqq0=";
        description = "The sha256 for the given version";
      };

      zsh.enable = mkEnableOption "Whether to enable zsh integration";
      bash.enable = mkEnableOption "Whether to enable bash integration";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = [
        (nvm cfg.version cfg.sha256)
      ];
    }

    (mkIf cfg.zsh.enable {
      programs.zsh.initExtra = initExtra;
    })

    (mkIf cfg.bash.enable {
      programs.bash.initExtra = initExtra;
    })
  ]);
}
