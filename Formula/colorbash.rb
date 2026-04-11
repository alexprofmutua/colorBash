class Colorbash < Formula
  desc "Color one exact folder name differently in terminal ls output"
  homepage "https://github.com/amm22-lab/colorBash"
  url "https://github.com/amm22-lab/colorBash/releases/download/v0.1.2/colorbash-v0.1.2.tar.gz"
  sha256 "12ea7dd90f1e871ca7c7886dd0828bd7b367fea9fdf54013462bb62e53a2b385"
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
