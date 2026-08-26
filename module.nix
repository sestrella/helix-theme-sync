{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.helix-theme-sync;
in
{
  options.services.helix-theme-sync = {
    enable = lib.mkEnableOption "helix-theme-sync, a service to keep the Helix theme in sync with the system appearance";

    package = lib.mkPackageOption pkgs "helix-theme-sync" {
      nullable = true;
      example = "pkgs.helix-theme-sync";
    };

    configThemesDir = lib.mkOption {
      type = lib.types.path;
      default = "${config.xdg.configHome}/helix/themes";
      defaultText = "~/.config/helix/themes";
      description = "Path to the Helix configuration themes directory";
    };

    runtimeThemesDir = lib.mkOption {
      type = lib.types.path;
      description = "Path to the Helix runtime themes directory";
    };

    theme = lib.mkOption {
      type = lib.types.str;
      description = "Name of the Helix theme to sync with the system appearance";
    };
  };

  config = lib.mkIf cfg.enable {
    launchd.agents.helix-theme-sync = {
      enable = true;

      config = {
        Program = lib.getExe cfg.package;
        ProgramArguments = [
          "--config-themes-dir"
          cfg.configThemesDir
          "--runtime-themes-dir"
          cfg.runtimeThemesDir
          "--theme"
          cfg.theme
        ];
        ProcessType = "Background";
        RunAtLoad = true;
        KeepAlive = {
          Crashed = true;
          SuccessfulExit = false;
        };
        StandardOutPath = "${config.xdg.stateHome}/helix-theme-sync/stdout.log";
        StandardErrorPath = "${config.xdg.stateHome}/helix-theme-sync/stderr.log";
      };
    };
  };
}
