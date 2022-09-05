class LibepoxyAngle < Formula
  desc "Library for handling OpenGL function pointer management"
  homepage "https://github.com/anholt/libepoxy"
  # waiting for upstreaming of https://github.com/akihikodaki/libepoxy/tree/macos
  url "https://github.com/akihikodaki/libepoxy.git", using: :git, revision: "ec54e0ff95dd98cd5d5c62b38d9ae427e4e6e747"
  version "20211208.1"
  license "MIT"

  bottle do
    root_url "https://github.com/akirakyle/homebrew-qemu-virgl/releases/download/v1"
    sha256 cellar: :any, arm64_monterey: "6a31b9554df5f37bd8fa3011b7745faab4eaf86712ad7125d9f4a02faa33b0a1"
  end

  keg_only "it conflicts with `libepoxy`"

  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build
  depends_on "python@3.10" => :build
  depends_on "akirakyle/qemu-virgl/libangle"

  def install
    mkdir "build" do
      system "meson", *std_meson_args,
             "-Dc_args=-I#{Formula["libangle"].opt_prefix}/include",
             "-Degl=yes", "-Dx11=false", ".."
      system "ninja", "-v"
      system "ninja", "install", "-v"
    end
  end

  test do
    (testpath/"test.c").write <<~EOS

      #include <epoxy/gl.h>
      #include <OpenGL/CGLContext.h>
      #include <OpenGL/CGLTypes.h>
      #include <OpenGL/OpenGL.h>
      int main()
      {
          CGLPixelFormatAttribute attribs[] = {0};
          CGLPixelFormatObj pix;
          int npix;
          CGLContextObj ctx;

          CGLChoosePixelFormat( attribs, &pix, &npix );
          CGLCreateContext(pix, (void*)0, &ctx);

          glClear(GL_COLOR_BUFFER_BIT);
          CGLReleasePixelFormat(pix);
          CGLReleaseContext(pix);
          return 0;
      }
    EOS
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lepoxy",
           "-framework", "OpenGL", "-o", "test"
    system "ls", "-lh", "test"
    system "file", "test"
    system "./test"
  end
end
