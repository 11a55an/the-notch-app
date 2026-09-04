import AppKit
import Combine

@MainActor
final class NowPlayingService: ObservableObject {
    @Published private(set) var info = NowPlayingInfo()

    private let spotifyBundleID = "com.spotify.client"
    private let musicBundleID = "com.apple.Music"
    private let chromeBundleID = "com.google.Chrome"

    private var timer: Timer?
    private var artworkCache: [String: NSImage] = [:]

    func startPolling() {
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
    }

    func stopPolling() {
        timer?.invalidate()
        timer = nil
    }

    func refresh() {
        Task.detached(priority: .utility) { [weak self] in
            guard let self else { return }
            let running = await self.runningPlayers()
            let result = await self.fetchNowPlaying(running: running)
            await MainActor.run {
                if result != self.info {
                    self.info = result
                }
            }
            await self.updateArtwork(for: result)
        }
    }

    func togglePlayPause() {
        let source = info.source
        Task.detached(priority: .userInitiated) {
            switch source {
            case .spotify:
                AppleScriptRunner.run("tell application \"Spotify\" to playpause")
            case .music:
                AppleScriptRunner.run("tell application \"Music\" to playpause")
            case .chrome:
                AppleScriptRunner.run(Self.chromeTogglePlaybackScript)
            case .none:
                break
            }
        }
    }

    func next() {
        send(spotify: "next track", music: "next track")
    }

    func previous() {
        send(spotify: "previous track", music: "previous track")
    }

    private func send(spotify spotifyCommand: String, music musicCommand: String) {
        let source = info.source
        Task.detached(priority: .userInitiated) {
            switch source {
            case .spotify:
                AppleScriptRunner.run("tell application \"Spotify\" to \(spotifyCommand)")
            case .music:
                AppleScriptRunner.run("tell application \"Music\" to \(musicCommand)")
            case .chrome, .none:
                break
            }
        }
    }

    private func updateArtwork(for result: NowPlayingInfo) async {
        guard let key = result.artworkCacheKey else { return }

        if let cached = artworkCache[key] {
            guard info == result else { return }
            info.artwork = cached
            return
        }

        let artwork = await fetchArtwork(for: result)
        guard info == result else { return }
        info.artwork = artwork
        if let artwork {
            artworkCache[key] = artwork
        }
    }

    nonisolated private func runningPlayers() async -> (spotify: Bool, music: Bool, chrome: Bool) {
        let apps = NSWorkspace.shared.runningApplications
        let spotify = apps.contains { $0.bundleIdentifier == spotifyBundleID }
        let music = apps.contains { $0.bundleIdentifier == musicBundleID }
        let chrome = apps.contains { $0.bundleIdentifier == chromeBundleID }
        return (spotify, music, chrome)
    }

    nonisolated private func fetchNowPlaying(running: (spotify: Bool, music: Bool, chrome: Bool)) async -> NowPlayingInfo {
        let candidates = [
            running.spotify ? fetchSpotify() : nil,
            running.music ? fetchMusic() : nil,
            running.chrome ? fetchChrome() : nil,
        ].compactMap { $0 }

        return candidates.first { $0.isPlaying } ?? candidates.first ?? NowPlayingInfo()
    }

    nonisolated private func fetchSpotify() -> NowPlayingInfo? {
        let script = """
        tell application "Spotify"
            if player state is playing or player state is paused then
                set trackName to name of current track
                set trackArtist to artist of current track
                set trackAlbum to album of current track
                set isNowPlaying to (player state is playing)
                return trackName & "\u{1F}" & trackArtist & "\u{1F}" & trackAlbum & "\u{1F}" & (isNowPlaying as string)
            else
                return ""
            end if
        end tell
        """
        return parseTrackInfo(AppleScriptRunner.runString(script), source: .spotify)
    }

    nonisolated private func fetchMusic() -> NowPlayingInfo? {
        let script = """
        tell application "Music"
            if player state is playing or player state is paused then
                set trackName to name of current track
                set trackArtist to artist of current track
                set trackAlbum to album of current track
                set isNowPlaying to (player state is playing)
                return trackName & "\u{1F}" & trackArtist & "\u{1F}" & trackAlbum & "\u{1F}" & (isNowPlaying as string)
            else
                return ""
            end if
        end tell
        """
        return parseTrackInfo(AppleScriptRunner.runString(script), source: .music)
    }

    nonisolated private func parseTrackInfo(_ raw: String?, source: NowPlayingSource) -> NowPlayingInfo? {
        guard let raw, !raw.isEmpty else { return nil }
        let parts = raw.components(separatedBy: "\u{1F}")
        guard parts.count == 4 else { return nil }
        var info = NowPlayingInfo()
        info.source = source
        info.title = parts[0]
        info.artist = parts[1]
        info.album = parts[2]
        info.isPlaying = parts[3] == "true"
        return info
    }

    nonisolated private static let chromeMediaQueryJS = "(function() { var els = document.querySelectorAll('video, audio'); for (var i = 0; i < els.length; i++) { if (els[i].readyState > 0) { return JSON.stringify({ title: document.title, playing: !els[i].paused && !els[i].ended }); } } return JSON.stringify({ title: '', playing: false }); })()"

    nonisolated private static let chromeToggleJS = "(function() { var els = document.querySelectorAll('video, audio'); for (var i = 0; i < els.length; i++) { if (els[i].readyState > 0) { els[i].paused ? els[i].play() : els[i].pause(); return 'true'; } } return 'false'; })()"

    nonisolated private static let chromeFindPlayingTabScript = """
    tell application "Google Chrome"
        set playingResult to ""
        set pausedResult to ""
        repeat with w in windows
            repeat with t in tabs of w
                try
                    set r to execute t javascript "\(chromeMediaQueryJS)"
                on error
                    set r to ""
                end try
                if r contains "\\"playing\\":true" then
                    set playingResult to r
                    exit repeat
                else if pausedResult is "" and r does not contain "\\"title\\":\\"\\"" then
                    set pausedResult to r
                end if
            end repeat
            if playingResult is not "" then exit repeat
        end repeat
        if playingResult is not "" then
            return playingResult
        else
            return pausedResult
        end if
    end tell
    """

    nonisolated private static let chromeTogglePlaybackScript = """
    tell application "Google Chrome"
        repeat with w in windows
            repeat with t in tabs of w
                try
                    set r to execute t javascript "\(chromeToggleJS)"
                on error
                    set r to "false"
                end try
                if r is "true" then return
            end repeat
        end repeat
    end tell
    """

    nonisolated private func fetchChrome() -> NowPlayingInfo? {
        guard let raw = AppleScriptRunner.runString(Self.chromeFindPlayingTabScript), !raw.isEmpty,
              let data = raw.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let title = json["title"] as? String, !title.isEmpty else { return nil }

        var info = NowPlayingInfo()
        info.source = .chrome
        info.title = title
        info.isPlaying = (json["playing"] as? Bool) ?? false
        return info
    }

    nonisolated private func fetchArtwork(for info: NowPlayingInfo) async -> NSImage? {
        switch info.source {
        case .spotify:
            return fetchSpotifyArtwork()
        case .music:
            return fetchMusicArtwork()
        case .chrome, .none:
            return nil
        }
    }

    nonisolated private func fetchSpotifyArtwork() -> NSImage? {
        guard let urlString = AppleScriptRunner.runString(
            "tell application \"Spotify\" to artwork url of current track"
        ), let url = URL(string: urlString) else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        return NSImage(data: data)
    }

    nonisolated private func fetchMusicArtwork() -> NSImage? {
        let script = """
        tell application "Music"
            if (count of artworks of current track) > 0 then
                return data of artwork 1 of current track
            end if
        end tell
        """
        guard let descriptor = AppleScriptRunner.run(script) else { return nil }
        guard let data = descriptor.data as Data? else { return nil }
        return NSImage(data: data)
    }
}
