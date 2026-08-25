# helix-theme-sync

[![build](https://github.com/sestrella/helix-theme-sync/actions/workflows/build.yml/badge.svg)](https://github.com/sestrella/helix-theme-sync/actions/workflows/build.yml)

Keep the [helix](https://github.com/helix-editor/helix) theme in sync with the system appearance on macOS.

## Setup

### Flake Input

Add `helix-theme-sync` as a flake input:

```nix
{
  inputs = {
    # ...
    helix-theme-sync.url = "github:sestrella/helix-theme-sync";
  };
}
```

### Home Manager Module

Import the overlay and the home module:

```nix
{
  outputs = { helix-theme-sync, ... }@inputs: {
    homeConfigurations.myuser = home-manager.lib.homeManagerConfiguration {
      # ...
      modules = [
        {
          nixpkgs.overlays = [
            helix-theme-sync.overlays.default
          ];
        }
        helix-theme-sync.homeModules.default
        # ...
      ];
    };
  };
}
```

### Service Configuration

```nix
{
  services.helix-theme-sync = {
    enable = true;

    configDir = "${config.home.homeDirectory}/.config/helix";
    runtimeDir = "${pkgs.helix-unwrapped.HELIX_DEFAULT_RUNTIME}";
    theme = config.programs.helix.settings.theme;
  };
}
```

## TODO

- Check if the theme is on sync when the service starts
