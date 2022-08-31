class Libangle < Formula
  desc "Conformant OpenGL ES implementation for Windows, Mac, Linux, iOS and Android"
  homepage "https://github.com/google/angle"
  url "https://github.com/google/angle.git", using: :git, revision: "4a65a669e11bd7bfa9d77cbf7001836379ec29b5"
  version "20220804.1"
  license "BSD-3-Clause"

  bottle do
    root_url "https://github.com/akirakyle/homebrew-qemu-virgl/releases/download/libangle-20211212.1"
    sha256 cellar: :any, arm64_big_sur: "6e776fc996fa02df211ee7e79512d4996558447bde65a63d2c7578ed1f63f660"
    sha256 cellar: :any, big_sur:       "1c201f77bb6d877f2404ec761e47e13b97a3d61dff7ddfc484caa3deae4e5c1b"
  end

  depends_on "meson" => :build
  depends_on "ninja" => :build

  # https://github.com/Homebrew/homebrew-core/pull/39157/files
  # Issue with creating relocatable bottles
  # https://github.com/Homebrew/brew/issues/12832
  
  resource "gn" do
    url "https://gn.googlesource.com/gn.git",
        :revision => "37baefb026b199605affa7bcb24810d1724ce373"
  end
  resource "build" do
    url "https://chromium.googlesource.com/chromium/src/build.git",
        :revision => "565e71d2102fc066fa81eeca84b287351349c05f"
  end
  resource "testing" do
    url "https://chromium.googlesource.com/chromium/src/testing.git",
        :revision => "3215569cc646be855f4730ab65e9f254ccd5d6fd"
  end
  resource "third_party/vulkan-deps" do
    url "https://chromium.googlesource.com/vulkan-deps.git",
        :revision => "00594ab942b503de4abfb817394bf5970256d2e3"
  end
  resource "third_party/vulkan-deps/vulkan-headers/src" do
    url "https://github.com/KhronosGroup/Vulkan-Headers.git",
        :revision => "3ef4c97fd6ea001d75a8e9da408ee473c180e456"
  end
  resource "third_party/vulkan-deps/glslang/src" do
    url "https://github.com/KhronosGroup/glslang.git",
        :revision => "adbf0d3106b26daa237b10b9bf72b1af7c31092d"
  end
  resource "third_party/vulkan-deps/spirv-headers/src" do
    url "https://github.com/KhronosGroup/SPIRV-Headers.git",
        :revision => "36c0c1596225e728bd49abb7ef56a3953e7ed468"
  end
  resource "third_party/vulkan-deps/spirv-tools/src" do
    url "https://github.com/KhronosGroup/SPIRV-Tools.git",
        :revision => "c94501352d545e84c821ce031399e76d1af32d18"
  end
  resource "third_party/SwiftShader" do
    url "https://swiftshader.googlesource.com/SwiftShader.git",
        :revision => "ee0d0b41a62640e0c37d1611f84e7533072c7256"
  end

  def install
    (buildpath/"gn").install resource("gn")
    cd "gn" do
      system "python3", "build/gen.py"
      system "ninja", "-C", "out/", "gn"
    end
    ENV.prepend_path "PATH", buildpath/"gn/out"

    (buildpath/"build").install resource("build")
    File.open('build/config/gclient_args.gni', "w") {|file|
      file.puts "generate_location_tags = false" }

    (buildpath/"testing").install resource("testing")
    (buildpath/"third_party/vulkan-deps").install resource("third_party/vulkan-deps")
    (buildpath/"third_party/vulkan-deps/vulkan-headers/src").install resource("third_party/vulkan-deps/vulkan-headers/src")
    (buildpath/"third_party/vulkan-deps/glslang/src").install resource("third_party/vulkan-deps/glslang/src")
    (buildpath/"third_party/vulkan-deps/spirv-headers/src").install resource("third_party/vulkan-deps/spirv-headers/src")
    (buildpath/"third_party/vulkan-deps/spirv-tools/src").install resource("third_party/vulkan-deps/spirv-tools/src")
    (buildpath/"third_party/SwiftShader").install resource("third_party/SwiftShader")

    system "gn", "gen", \
           "--args=is_debug=false", \
           "./angle_build"
    system "ninja", "-C", "angle_build"
    lib.install "angle_build/libEGL.dylib"
    lib.install "angle_build/libGLESv2.dylib"
    include.install Pathname.glob("include/*")
  end

  test do
    system "true"
  end
end
