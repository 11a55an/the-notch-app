import SwiftUI
import Combine

@MainActor
final class NotchViewModel: ObservableObject {
    @Published var isExpanded = false {
        didSet {
            guard oldValue != isExpanded else { return }
            onExpandedChanged?(isExpanded)
        }
    }
    @Published var selectedTab: NotchTab = .nowPlaying

    let nowPlaying = NowPlayingService()
    let calendar = CalendarService()
    let stats = SystemStatsService()
    let shelf = FileShelfService()

    var onExpandedChanged: ((Bool) -> Void)?

    private var collapseWorkItem: DispatchWorkItem?

    init() {
        nowPlaying.startPolling()
        stats.startPolling()
        calendar.requestAccessAndRefresh()
    }

    func setHovering(_ hovering: Bool) {
        collapseWorkItem?.cancel()

        if hovering {
            withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
                isExpanded = true
            }
        } else {
            let work = DispatchWorkItem { [weak self] in
                guard let self else { return }
                withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
                    self.isExpanded = false
                }
            }
            collapseWorkItem = work
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: work)
        }
    }
}
