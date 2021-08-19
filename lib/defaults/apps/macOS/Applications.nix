{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.macOS.apps.symlinks;

in
{
  options = {
    macOS.apps.symlinks = {
      enable = mkOption {
        default = false;
        description = "Whether to enable ~/Applications symlinking.";
      };
      path = mkOption {
        default = "~/Applications/Nix";
        description = "The directory path to symlink apps to.";
      };
    };
  };

  config = {
    home.activation = lib.optionals cfg.enable {
      aliasApplications = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        app_folder=$(echo ${cfg.path});
        mkdir -p $app_folder

        IFS=$'\n'
        old_paths=($(mdfind kMDItemKind="Alias" -onlyin "$app_folder"))
        new_paths=($(find "$genProfilePath/home-path/Applications" -name '*.app' -type l))
        unset IFS

        old_size="''${#old_paths[@]}"
        echo "removing $old_size aliased apps from $app_folder"
        for i in "''${!old_paths[@]}"; do
          $DRY_RUN_CMD rm -f "''${old_paths[$i]}"
        done

        new_size="''${#new_paths[@]}"
        echo "adding $new_size aliased apps into $app_folder"

        for i in "''${!new_paths[@]}"; do
          real_app=$(realpath "''${new_paths[$i]}")
          app_name=$(basename "''${new_paths[$i]}")
          $DRY_RUN_CMD rm -f "$app_folder/$app_name"
          $DRY_RUN_CMD osascript \
            -e "tell app \"Finder\"" \
            -e "make new alias file at POSIX file \"$app_folder\" to POSIX file \"$real_app\"" \
            -e "set name of result to \"$app_name\"" \
            -e "end tell"
        done
      '';
    };
  };
}
