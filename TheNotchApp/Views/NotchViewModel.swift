import SwiftUI
import Combine

@MainActor
final class NotchViewModel: ObservableObject {
    @Published var isExpanded = false
    @Published var hasPhysicalNotch = NotchGeometry.current().hasPhysicalNotch

    let nowPlaying = NowPlayingService()
    let calendar = CalendarService()
    let stats = SystemStatsService()
    let shelf = FileShelfService()
    let premierLeague = PremierLeagueScoreService()

    private var collapseWorkItem: DispatchWorkItem?

    init() {
        nowPlaying.startPolling()
        stats.startPolling()
        calendar.requestAccessAndRefresh()
        premierLeague.startPolling()
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
