class Freeai < Formula
  desc "CLI for generating and executing AI-generated shell scripts"
  homepage "https://github.com/astikspandey/freeai"
  url "https://raw.githubusercontent.com/astikspandey/freeai/v1.0.0/freeai"
  sha256 "d5558cd419c8d46bdc958064cb97f963d1ea793866414c025906ec15033512ed"
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
