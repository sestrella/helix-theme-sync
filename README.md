# helix-theme-sync

[![Build](https://github.com/sestrella/helix-theme-sync/actions/workflows/build.yml/badge.svg)](https://github.com/sestrella/helix-theme-sync/actions/workflows/build.yml)

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
{ config, pkgs, ... }:

{
  programs.helix = {
    enable = true;

    settings = {
      theme = "solarized";
    };
  };

  services.helix-theme-sync = {
    enable = true;

    configThemesDir = "${config.xdg.configHome}/helix/themes";
    runtimeThemesDir = "${pkgs.helix-unwrapped.HELIX_DEFAULT_RUNTIME}/themes";
    theme = config.programs.helix.settings.theme;
  };
}
```

For a complete usage example, see [home-manager.config/home/helix/default.nix](https://github.com/sestrella/home-manager.config/blob/main/home/helix/default.nix).

### Homebrew

Install the formula from this repository's tap, then start its per-user service:

```sh
brew tap sestrella/helix-theme-sync https://github.com/sestrella/helix-theme-sync
brew install helix-theme-sync
brew services start helix-theme-sync
```

The service reads the top-level `theme` setting from `~/.config/helix/config.toml` and uses Homebrew's Helix runtime. It creates or updates the corresponding theme symlink in `~/.config/helix/themes` when the macOS appearance changes; back up any existing `~/.config/helix/themes/<theme>.toml` first, as it will be replaced by the symlink. Set `theme = "..."` in the Helix config before starting the service.

## TODO

- Check if the theme is on sync when the service starts
