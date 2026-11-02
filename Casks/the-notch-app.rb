cask "the-notch-app" do
  version "0.1.0"
  sha256 "3491c12ad352d2f24953fdc11ec04a1b4586caae9d3dfe2718ae4cebdb15afe4"

  url "https://github.com/11a55an/the-notch-app/releases/download/v#{version}/TheNotchApp-#{version}.zip"
  name "The Notch App"
  desc "Turns the MacBook notch into a hover-activated dashboard with live scores"
  homepage "https://github.com/11a55an/the-notch-app"

  depends_on macos: ">= :sonoma"

  app "The Notch App.app"

  zap trash: [
    "~/Library/Preferences/com.hassan.notchy.app.plist",
  ]

  caveats <<~EOS
    The Notch App isn't notarized by Apple (it's a solo indie project, not
    worth the $99/yr developer account yet). Homebrew removes the
    quarantine flag for you, so it should open without a Gatekeeper warning.

    If macOS still blocks it, run:
      xattr -dr com.apple.quarantine "/Applications/The Notch App.app"

    The app has no Dock icon or menu bar window by design — look for its
    icon in the menu bar status items, and for the panel itself hovering
    over (or near) the notch.
  EOS
end
