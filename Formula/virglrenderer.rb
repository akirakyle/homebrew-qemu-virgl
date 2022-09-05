class Virglrenderer < Formula
  desc "VirGL virtual OpenGL renderer"
  homepage "https://gitlab.freedesktop.org/virgl/virglrenderer"
  # waiting for upstreaming of https://github.com/akihikodaki/virglrenderer/tree/macos
  url "https://github.com/akihikodaki/virglrenderer.git", revision: "23f309ff0cf677b16d44c62f72ff01a84f845962"
  version "20220219.1"
  license "MIT"
  # A

  bottle do
    root_url "https://github.com/akirakyle/homebrew-qemu-virgl/releases/download/virglrenderer-20220219.1"
    rebuild 1
    sha256 cellar: :any, monterey: "a3f478a34da83228e72dff286e4576d6c75a972facb65ab0669a3381af43dd5c"
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "akirakyle/qemu-virgl/libepoxy-angle"

  def install
    mkdir "build" do
      system "meson", *std_meson_args,
             "-Dc_args=-I#{Formula["libepoxy-angle"].opt_prefix}/include",
             "-Dc_link_args=-L#{Formula["libepoxy-angle"].opt_prefix}/lib", ".."
      system "ninja", "-v"
      system "ninja", "install", "-v"
    end
  end

  test do
    system "true"
  end
end
