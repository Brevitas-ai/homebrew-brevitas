# Homebrew formula for the Brevitas installer CLI (command: bvx).
#
# The command is named `bvx` to avoid colliding with the brevitas-systems
# Python package's own `brevitas` CLI.
#
# This installs a PREBUILT binary per platform — no Go toolchain or Xcode
# Command Line Tools are required. `brew install --HEAD` builds from source.
#
# The optimization logic (brevitas-systems) is a separate Python package and is
# NOT bundled here — `bvx install` / `bvx update` manage it via pip.
class Bvx < Formula
  desc "Middleware installer that routes AI coding assistants through Brevitas"
  homepage "https://github.com/Brevitas-ai/brevitas"
  version "0.1.21"
  license "MIT"

  # Bleeding-edge source build (requires Go, only used with --HEAD).
  head do
    url "https://github.com/Brevitas-ai/brevitas.git", branch: "main"
    depends_on "go" => :build
  end

  depends_on "python@3.13"

  on_macos do
    on_arm do
      url "https://github.com/Brevitas-ai/brevitas/releases/download/v0.1.21/bvx-0.1.21-darwin-arm64.tar.gz"
      sha256 "2c89e3cd533b8a4b2f32bacb49667d9df78c9a2fffd13414178d2d6825bf7897"
    end
    on_intel do
      url "https://github.com/Brevitas-ai/brevitas/releases/download/v0.1.21/bvx-0.1.21-darwin-amd64.tar.gz"
      sha256 "52dfce91e887a0fcfb7804646366c995c474466810e316fa345eea89f261be68"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Brevitas-ai/brevitas/releases/download/v0.1.21/bvx-0.1.21-linux-arm64.tar.gz"
      sha256 "2322ef4e74fee15f94a9c27987323d7ff73bfedeaa60dce105dc03f159d2ec4c"
    end
    on_intel do
      url "https://github.com/Brevitas-ai/brevitas/releases/download/v0.1.21/bvx-0.1.21-linux-amd64.tar.gz"
      sha256 "89ff2f2df20ff510b99029f9ac242256b99770bfaac8b8d4ff1557d3d60998a7"
    end
  end

  def install
    if build.head?
      ldflags = %W[
        -s -w
        -X github.com/Brevitas-ai/brevitas/internal/version.Version=HEAD
        -X github.com/Brevitas-ai/brevitas/internal/version.Date=#{time.iso8601}
      ]
      system "go", "build", *std_go_args(ldflags: ldflags, output: bin/"bvx"), "./cmd/bvx"
    else
      bin.install "bvx"
    end
  end

  def caveats
    <<~EOS
      Brevitas configures your AI coding tools to route through a local proxy.

      Next steps:
        bvx install     # sign in, detect tools, configure, start

      bvx installs and pins the brevitas-systems optimization engine automatically.
      Run `bvx update` later to keep it current.
    EOS
  end

  service do
    run [opt_bin/"bvx", "serve"]
    keep_alive true
    log_path var/"log/brevitas/proxy.out.log"
    error_log_path var/"log/brevitas/proxy.err.log"
  end

  test do
    assert_match "brevitas", shell_output("#{bin}/bvx version")
    assert_match "Commands:", shell_output("#{bin}/bvx help")
  end
end
