# The Notch App

A macOS menu bar app that turns the notch into a hover-activated panel: now playing (Spotify/Apple Music) with controls, today's calendar events, system stats, and a file shelf.

## Requirements

- macOS 14+
- Xcode 16+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

## Setup

```sh
xcodegen generate
open Notchy.xcodeproj
```

Build and run from Xcode. The app has no dock icon or main window; look for the notch panel and the menu bar icon.

## Now playing

Now-playing data comes from AppleScript (Apple Events) against Spotify and Music.app, not the private MediaRemote framework, so the app can eventually be sandboxed for Mac App Store distribution. This means only Spotify and Apple Music are supported, not arbitrary apps.
