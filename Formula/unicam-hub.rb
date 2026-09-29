# Rendered by .github/workflows/go.yml on every stable release and pushed to
# nittbit/homebrew-tap as Formula/unicam-hub.rb.
# Placeholders: 0.9.0, baaf710781cf2e3b5a877dd8277e9bb299cd234a1d95dbdad2f2dfb85df89a08, b3eb026a6ab362e1257a1395478d8a736c885a4e2f64f6ffc839e15811eef307,
#               b7adf4d7d9e440d372f1e5cae8547e354567441794f193c3b5979c7152dfea7f
class UnicamHub < Formula
  desc "Video recording hub daemon and CLI for IP cameras and RTSP streams"
  homepage "https://unicam.app"
  version "0.9.0"

  on_macos do
    # Apple Silicon only; Intel Macs are not supported.
    depends_on arch: :arm64

    on_arm do
      url "https://github.com/nittbit/unicam-releases/releases/download/v0.9.0/unicam-hub_0.9.0_macos-arm64.tar.gz"
      sha256 "baaf710781cf2e3b5a877dd8277e9bb299cd234a1d95dbdad2f2dfb85df89a08"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/nittbit/unicam-releases/releases/download/v0.9.0/unicam-hub_0.9.0_linux-arm64.tar.gz"
      sha256 "b7adf4d7d9e440d372f1e5cae8547e354567441794f193c3b5979c7152dfea7f"
    end
    on_intel do
      url "https://github.com/nittbit/unicam-releases/releases/download/v0.9.0/unicam-hub_0.9.0_linux-amd64.tar.gz"
      sha256 "b3eb026a6ab362e1257a1395478d8a736c885a4e2f64f6ffc839e15811eef307"
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
