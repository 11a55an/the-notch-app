import AppKit

enum NowPlayingSource: String {
    case spotify = "Spotify"
    case music = "Music"
    case none = "None"

    var symbolName: String {
        switch self {
        case .spotify: return "music.note"
        case .music: return "music.note"
        case .none: return "speaker.slash"
        }
    }
}

struct NowPlayingInfo: Equatable {
    var source: NowPlayingSource = .none
    var title: String = ""
    var artist: String = ""
    var album: String = ""
    var isPlaying: Bool = false
    var artwork: NSImage?

    static func == (lhs: NowPlayingInfo, rhs: NowPlayingInfo) -> Bool {
        lhs.source == rhs.source &&
        lhs.title == rhs.title &&
        lhs.artist == rhs.artist &&
        lhs.album == rhs.album &&
        lhs.isPlaying == rhs.isPlaying
    }

    var isActive: Bool { source != .none && !title.isEmpty }

    var artworkCacheKey: String? {
        guard source != .none else { return nil }
        return "\(source.rawValue)|\(title)|\(album)"
    }
}
