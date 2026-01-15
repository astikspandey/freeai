class Freeai < Formula
  desc "CLI for generating and executing AI-generated shell scripts"
  homepage "https://github.com/astikspandey/freeai"
  url "https://raw.githubusercontent.com/astikspandey/freeai/v1.0.0/freeai"
  sha256 "93c723b63118a1068cc28cc79cf4317462167dd88e744ea3d687b9fd0ae0ac76"
  license "MIT"

  def install
    bin.install "freeai"
  end

  def caveats
    <<~EOS
      FreeAI requires a local API server running at:
        http://localhost:5000

      Usage:
        freeai <context_file> <prompt>
    EOS
  end
end
