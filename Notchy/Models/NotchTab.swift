import Foundation

enum NotchTab: String, CaseIterable, Identifiable {
    case nowPlaying = "Now Playing"
    case calendar = "Calendar"
    case stats = "Stats"
    case shelf = "Shelf"

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .nowPlaying: return "waveform"
        case .calendar: return "calendar"
        case .stats: return "gauge.with.dots.needle.50percent"
        case .shelf: return "tray.and.arrow.down"
        }
    }
}
