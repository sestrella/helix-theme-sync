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

    configDir = lib.mkOption {
      type = lib.types.path;
    };

    runtimeDir = lib.mkOption {
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
          "--config-dir"
          cfg.configDir
          "--runtime-dir"
          cfg.runtimeDir
          "--theme"
          cfg.theme
        ];
        ProcessType = "Background";
        RunAtLoad = true;
        KeepAlive = {
          Crashed = true;
          SuccessfulExit = false;
        };
        # TODO: configure this values
        StandardOutPath = "${config.home.homeDirectory}/.local/state/helix-theme-sync/logs/out.log";
        StandardErrorPath = "${config.home.homeDirectory}/.local/state/helix-theme-sync/logs/err.log";
      };
    };
  };
}
