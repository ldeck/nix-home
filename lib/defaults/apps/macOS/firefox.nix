{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.macOS.apps.firefox;
in {
  options = {
    macOS.apps.firefox = {
      enable = mkOption {
        default = false;
        description = "Whether to enable this app.";
      };
      version = mkOption {
        default = "92.0.1";
        description = "The version of the app";
      };
      sha256 = mkOption {
        default = "1sy856rbfavzbyhrb7kii0k32v674nv67vqr7a6211db2nii297q";
        description = "The sha256 for the defined version";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages =
      (pkgs.callPackage ./lib/app.nix rec {
        name = "Firefox";
        sourceRoot = "Firefox.app";
        version = cfg.version;
        src = pkgs.fetchurl {
          url = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/${version}/mac/en-US/Firefox+${version}.dmg";
          sha256 = cfg.sha256;
          name = "Firefox-${version}.dmg";
        };
        description = "The Firefox web browser";
        homepage = https://www.mozilla.org/en-US/firefox/;
        appcast = https://www.mozilla.org/en-US/firefox/releases/;
      });
  };
}
