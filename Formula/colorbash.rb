class Colorbash < Formula
  desc "Color exact file and folder names differently in terminal ls output"
  homepage "https://github.com/amm22-lab/colorBash"
  url "https://github.com/amm22-lab/colorBash/releases/download/v0.1.3/colorbash-v0.1.3.tar.gz"
  sha256 "a33898207b974831123f99587a885ea0f8816bbb894b41617a689ff3d5e7d58a"
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
