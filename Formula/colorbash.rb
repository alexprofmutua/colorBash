class Colorbash < Formula
  desc "Color one exact folder name differently in terminal ls output"
  homepage "https://github.com/amm22-lab/colorBash"
  url "https://github.com/amm22-lab/colorBash/releases/download/v0.1.0/colorbash-v0.1.0.tar.gz"
  sha256 "f0dc9a02d1e7f671bf60566a48594269d992c07a2efa50e835168f28f5f4bcf7"
  license "AGPL-3.0-only"

  def install
    bin.install "colorbash", "cb"
    pkgshare.install "README.md", "LICENSE", "LICENSING.md", "VERSION"
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
