# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class Dubfinder < Formula
  desc "dub finder tool description"
  homepage "colins-blog.pandia.io"
  url "https://github.com/codefuturist/monorepo/releases/download/v0.1.3/monorepo_v0.1.3_x86_64-unknown-linux-musl.tar.gz"
  sha256 "184ecb9517aee0c5df44782cae56489cd8bda7f3a2ed9fb88da2a7f7792eb2d6"
  license "MIT"


  
  if OS.linux?
    if Hardware::CPU.intel?
      url "https://github.com/codefuturist/monorepo/releases/download/v0.1.3/monorepo_v0.1.3_x86_64-unknown-linux-musl.tar.gz"
      sha256 "184ecb9517aee0c5df44782cae56489cd8bda7f3a2ed9fb88da2a7f7792eb2d6"
    elsif Hardware::CPU.arm?
      url "https://github.com/codefuturist/monorepo/releases/download/v0.1.3/monorepo_v0.1.3_x86_64-unknown-linux-musl.tar.gz"
      sha256 "184ecb9517aee0c5df44782cae56489cd8bda7f3a2ed9fb88da2a7f7792eb2d6"
    end
  elsif OS.mac?
    if Hardware::CPU.intel?
      url "https://github.com/codefuturist/monorepo-public/releases/download/v0.0.2/monorepo_v0.1.3_x86_64-pc-windows-gnu.zip"
      sha256 "0f99a27728786c486820d3a84eb05153ed57b7357b3e64f7a45f5b21e12643ae"
    elsif Hardware::CPU.arm?
      url "https://github.com/codefuturist/monorepo-public/releases/download/v0.0.2/monorepo_v0.1.3_x86_64-pc-windows-gnu.zip"
      sha256 "0f99a27728786c486820d3a84eb05153ed57b7357b3e64f7a45f5b21e12643ae"
    end
  end
  
  # depends_on "cmake" => :build

  def install
    # Remove unrecognized options if they cause configure to fail
    # https://rubydoc.brew.sh/Formula.html#std_configure_args-instance_method
    # system "./configure", "--disable-silent-rules", *std_configure_args
    # system "cmake", "-S", ".", "-B", "build", *std_cmake_args

    if OS.linux?
      bin.install "dub-finder"
    elsif OS.mac?
      bin.install "dub-finder.exe"
    end
    
    
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test dub-finder`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end
