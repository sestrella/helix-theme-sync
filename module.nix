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
    enable = lib.mkEnableOption "TODO";

    package = lib.mkPackageOption pkgs "helix-theme-sync" {
      nullable = true;
      example = "pkgs.helix-theme-sync";
    };

    configThemesDir = lib.mkOption {
      type = lib.types.path;
      default = "${config.xdg.configHome}/helix/themes";
      defaultText = "~/.config/helix/themes";
    };

    runtimeThemesDir = lib.mkOption {
      type = lib.types.path;
    };

    theme = lib.mkOption {
      type = lib.types.str;
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
