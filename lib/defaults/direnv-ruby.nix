{ pkgs, lib, config, ... }:

with lib;

let

  cfg = config.programs.direnv;

in
{
  options = {
    programs.direnv = {
      use_chruby = {
        enable = mkOption {
          default = false;
          description = "Whether to enable the use of chruby in direnv";
        };
        script = mkOption {
          type = types.str;
          default = ''
            use_ruby() {
              # enable the chruby command in an environment
              source ${pkgs.chruby}/share/chruby/chruby.sh

              # desired Ruby version as first parameter
              local ver=$1

              # if version not given as parameter and there is a .ruby-version file, get
              # version from the file
              if [[ -z $ver ]] && [[ -f .ruby-version ]]; then
                ver=$(cat .ruby-version)
              fi

              # if the version still isn't set, error cause we don't know what to do
              if [[ -z $ver ]]; then
                echo Unknown ruby version
                exit 1
              fi

              # switch to the desired ruby version
              chruby $ver

              # Sets the GEM_HOME environment variable to `$PWD/.direnv/ruby/RUBY_VERSION`.
              # This forces the installation of any gems into the project’s sub-folder. If
              # you’re using bundler it will create wrapper programs that can be invoked
              # directly instead of using the `bundle exec` prefix.
              layout_ruby
            }
          '';
        };
      };
    };
  };

  config = mkIf (cfg.use_chruby.enable) {
    programs.direnv.stdlib = mkAfter ''
      ${if cfg.use_chruby.enable then cfg.use_chruby.script else ""}
    '';
  };
}
