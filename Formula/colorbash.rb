class Colorbash < Formula
  desc "Color one exact folder name differently in terminal ls output"
  homepage "https://github.com/amm22-lab/colorBash"
  url "https://github.com/alexprof/colorBash/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "99f925d23fd23216a9ec88e2ab1775d8d99c6f36764cbdb1192a40775fb9f315"
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
