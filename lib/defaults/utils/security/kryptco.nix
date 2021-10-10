{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.utils.security.kryptco.kr;

in
{
  options = {
    utils.security.kryptco.kr = {
      enable = lib.mkOption {
        default = false;
        description = "Whether to enable Kryptco ssh shell integration.";
      };

      version = lib.mkOption {
        default = "2.4.15";
        description = "The human readable Kryptco version";
      };

      revision = lib.mkOption {
        default = "1937e31606e4dc0f7263133334d429f956502276";
        description = "The Kryptco github revision";
      };

      sha256 = lib.mkOption {
        default = "13ch85f1y4j2n4dbc6alsxbxfd6xnidwi2clibssk5srkz3mx794";
        description = "The Kryptco github revisoin's sha256";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      (pkgs.stdenv.mkDerivation rec {
        name = "kr-${version}";
        version = cfg.version;

        src = pkgs.fetchFromGitHub {
          owner = "kryptco";
          repo = "kr";
          rev = cfg.revision;
          sha256 = cfg.sha256;
        };

        buildInputs = [ pkgs.go ];

        makeFlags = [
          "PREFIX=$(out)"
          "GOPATH=$(out)/share/go"
          "GOCACHE=$(TMPDIR)/go-cache"
        ];

        preInstall = ''
          mkdir -p $out/share/go
        '';

        meta = with lib; {
          description = "A dev tool for SSH auth + Git commit/tag signing using a key stored in Krypton.";
          homepage = "https://krypt.co";
          license = licenses.unfreeRedistributable;
          platforms = platforms.linux ++ platforms.darwin;
        };
      })
    ];
  };
}
