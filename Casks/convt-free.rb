cask "convt-free" do
  version "0.5.0-1793747519.1f5fd5732f7c.c29ba7390793"
  sha256 "a9dc0e06b82768cded3165f9077a783ddd8ca88817d52742ce886dd6b2b7295d"

  url "https://github.com/KKKKeybird/convt/releases/download/free-1f5fd5732f7c-c29ba7390793/convt-free-0.5.0-1793747519.1f5fd5732f7c.c29ba7390793-arm64.zip"
  name "convt Free (unofficial source build)"
  desc "Local file converter with Finder Quick Action"
  homepage "https://github.com/KKKKeybird/convt"

  depends_on arch: :arm64
  depends_on macos: ">= :ventura"
  conflicts_with cask: "convt"

  app "convt.app"
  binary "#{appdir}/convt.app/Contents/MacOS/convt", target: "convt-free"
  artifact "convt-free.workflow", target: "#{Dir.home}/Library/Services/convt-free.workflow"

  caveats <<~EOS
    This unofficial build is ad-hoc signed and is not notarized by Apple.
    First open may require approval in System Settings > Privacy & Security.
    Enable "Convert with convt Free" in Finder Quick Actions / Services.
    The native FinderSync format submenu requires Apple team signing.
    Office conversions need: brew install --cask libreoffice
    Do not install alongside an official or manually installed convt.app.
    Homebrew does not grant Apple notarization or App Group permissions.
  EOS
end
