class HelixThemeSync < Formula
  desc "Keep the Helix theme in sync with macOS appearance"
  homepage "https://github.com/sestrella/helix-theme-sync"
  url "https://github.com/sestrella/helix-theme-sync/releases/download/v#{version}/helix-theme-sync-macos-arm64-v#{version}.tar.gz"
  version "0.1.0"
  sha256 "19615c74ee7e96f1443a90a92226e6551c82e84f199272bb33bb1093d131ce77"
  license "MIT"

  depends_on arch: :arm64
  depends_on "helix"

  def install
    bin.install "helix-theme-sync"

    (bin/"helix-theme-sync-service").write <<~SH
      #!/bin/sh
      config="$HOME/.config/helix/config.toml"
      if [ ! -r "$config" ]; then
        echo "Cannot read Helix config: $config" >&2
        exit 1
      fi

      theme=$(/usr/bin/awk '
        /^theme[[:space:]]*=/ {
          value = $0
          sub(/^[^=]*=[[:space:]]*/, "", value)
          sub(/[[:space:]]+#.*/, "", value)
          gsub(/["\\047]/, "", value)
          print value
          exit
        }
      ' "$config")
      if [ -z "$theme" ]; then
        echo "No top-level theme setting found in $config" >&2
        exit 1
      fi

      exec "#{opt_bin}/helix-theme-sync" \\
        --config-themes-dir "$HOME/.config/helix/themes" \\
        --runtime-themes-dir "#{HOMEBREW_PREFIX}/opt/helix/libexec/runtime/themes" \\
        --theme "$theme"
    SH
    (bin/"helix-theme-sync-service").chmod 0755
  end

  service do
    run [opt_bin/"helix-theme-sync-service"]
    keep_alive true
    log_path var/"log/helix-theme-sync.log"
    error_log_path var/"log/helix-theme-sync.log"
  end

  test do
    assert_match "0.1.0", shell_output("#{bin}/helix-theme-sync --version")
  end
end
