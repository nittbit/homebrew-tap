# Rendered by .github/workflows/go.yml on every stable release and pushed to
# nittbit/homebrew-tap as Formula/unicam-hub.rb.
# Placeholders: 0.9.1, b55e3bf0dd83301f756379d76553d4c901249eff17086960519b0cc24cbac327, 555580690464ff8e0c398ff52f86a18e562d5a907d190cdad077ff102dafa653,
#               e2edeacfe2b12faa5b28e804241260cb140b17c3f64b268547248a22ee694d47
class UnicamHub < Formula
  desc "Video recording hub daemon and CLI for IP cameras and RTSP streams"
  homepage "https://unicam.app"
  version "0.9.1"

  # Keep @rpath dylib IDs. Otherwise Homebrew rewrites them to absolute paths and
  # ad-hoc re-signs each dylib, which breaks the .app bundle's Developer ID seal;
  # Gatekeeper then rejects the app as damaged and offers to move it to the Trash.
  preserve_rpath

  on_macos do
    # Apple Silicon only; Intel Macs are not supported.
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/nittbit/unicam-releases/releases/download/v0.9.1/unicam-hub_0.9.1_macos-arm64.tar.gz"
      sha256 "b55e3bf0dd83301f756379d76553d4c901249eff17086960519b0cc24cbac327"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/nittbit/unicam-releases/releases/download/v0.9.1/unicam-hub_0.9.1_linux-arm64.tar.gz"
      sha256 "e2edeacfe2b12faa5b28e804241260cb140b17c3f64b268547248a22ee694d47"
    end
    on_intel do
      url "https://github.com/nittbit/unicam-releases/releases/download/v0.9.1/unicam-hub_0.9.1_linux-amd64.tar.gz"
      sha256 "555580690464ff8e0c398ff52f86a18e562d5a907d190cdad077ff102dafa653"
    end
  end

  def install
    if OS.mac?
      # Keep the signed .app bundle intact: rpaths point at Contents/Frameworks
      # and the daemon locates bundled ffmpeg/ffprobe next to its executable.
      app = Dir["*.app"].first
      odie "no .app bundle in tarball" if app.nil?
      libexec.install app
      bin.write_exec_script libexec/app/"Contents/MacOS/unicam-hub"
    else
      # RUNPATH only covers direct deps; the binary, ffmpeg and ffprobe all need LD_LIBRARY_PATH.
      libexec.install "bin", "lib"
      bin.write_env_script libexec/"bin/unicam-hub", LD_LIBRARY_PATH: libexec/"lib"
    end
    bin.install_symlink "unicam-hub" => "unicam"
  end

  service do
    run [opt_bin/"unicam-hub", "serve"]
    keep_alive true
    log_path var/"log/unicam-hub.log"
    error_log_path var/"log/unicam-hub.log"
  end

  def caveats
    <<~EOS
      Start the hub daemon as a background service:
        brew services start unicam-hub
      Then open the UI or use the CLI:
        unicam status
      Updates are installed with:
        brew upgrade unicam-hub
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/unicam --version")
  end
end
