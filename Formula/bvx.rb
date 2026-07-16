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
  version "0.1.22"
  license "MIT"

  # Bleeding-edge source build (requires Go, only used with --HEAD).
  head do
    url "https://github.com/Brevitas-ai/brevitas.git", branch: "main"
    depends_on "go" => :build
  end

  depends_on "python@3.13"

  on_macos do
    on_arm do
      url "https://github.com/Brevitas-ai/brevitas/releases/download/v0.1.22/bvx-0.1.22-darwin-arm64.tar.gz"
      sha256 "22f173f8703bc20d9643e28b627fe5d5846718b2ebe69a586559691f437c27d7"
    end
    on_intel do
      url "https://github.com/Brevitas-ai/brevitas/releases/download/v0.1.22/bvx-0.1.22-darwin-amd64.tar.gz"
      sha256 "23cf3a1b2ef98bf8fd156b20e4379661a9a33c15105c99460602345826081f3a"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Brevitas-ai/brevitas/releases/download/v0.1.22/bvx-0.1.22-linux-arm64.tar.gz"
      sha256 "04eda7fcae23b28e81c304b9e9886f8f51871131c1fd9b67b4e24569ed7ccbce"
    end
    on_intel do
      url "https://github.com/Brevitas-ai/brevitas/releases/download/v0.1.22/bvx-0.1.22-linux-amd64.tar.gz"
      sha256 "fdf6df41958b55ee6f85b7dba00e23afcc853ff99f8bae011d072532de7ef2d6"
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
