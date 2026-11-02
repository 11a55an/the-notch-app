cask "the-notch-app" do
  version "0.1.1"
  sha256 "df7ca363dea668e9eabd89771167b1f19ba116348480ebe543f5ead99f4a3f4c"

  url "https://github.com/11a55an/the-notch-app/releases/download/v#{version}/TheNotchApp-#{version}.zip"
  name "The Notch App"
  desc "Turns the MacBook notch into a hover-activated dashboard with live scores"
  homepage "https://github.com/11a55an/the-notch-app"

  depends_on macos: :sonoma

  app "The Notch App.app"

  zap trash: [
    "~/Library/Preferences/com.hassan.notchy.app.plist",
  ]

  caveats <<~EOS
    The Notch App isn't notarized by Apple (it's a solo indie project, not
    worth the $99/yr developer account yet), so macOS will likely say it's
    from an "unidentified developer" on first launch. Either click through
    via System Settings → Privacy & Security → Open Anyway, or run:
      xattr -dr com.apple.quarantine "/Applications/The Notch App.app"

    The app has no Dock icon or menu bar window by design — look for its
    icon in the menu bar status items, and for the panel itself hovering
    over (or near) the notch.
  EOS
end
