class Colorbash < Formula
  desc "Color exact file and folder names differently in terminal ls output"
  homepage "https://github.com/amm22-lab/colorBash"
  url "https://github.com/amm22-lab/colorBash/releases/download/v0.1.4/colorbash-v0.1.4.tar.gz"
  sha256 "88deb3744bf6d358e684e07c7ba1bc516e81e3b3cfb33832a9b4f8941d5ce056"
  license "AGPL-3.0-only"

  def install
    bin.install "colorbash", "cb"
    pkgshare.install "README.md", "LICENSE", "LICENSING.md", "VERSION", "colorbash-init.sh"
  end

  def caveats
    <<~EOS
      Add colorbash to your shell startup:
        eval "$(colorbash init)"
    EOS
  end

  test do
    ENV["COLORBASH_CONFIG_DIR"] = testpath/".config/colorbash"
    system bin/"colorbash", "test_case", "red"
    output = shell_output("#{bin}/colorbash list")
    assert_match "test_case", output
    assert_match "red", output
  end
end
