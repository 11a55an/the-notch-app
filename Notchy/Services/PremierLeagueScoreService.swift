import AppKit
import Combine

@MainActor
final class PremierLeagueScoreService: ObservableObject {
    @Published private(set) var liveMatch: LiveMatchInfo?
    @Published private(set) var isDismissed = false
    @Published var favoriteTeamID: String? {
        didSet {
            guard oldValue != favoriteTeamID else { return }
            UserDefaults.standard.set(favoriteTeamID, forKey: Self.favoriteTeamKey)
            dismissedMatchID = nil
            refresh()
        }
    }

    private static let favoriteTeamKey = "Notchy.favoriteTeamID"
    private static let scoreboardURL = URL(string: "https://site.api.espn.com/apis/site/v2/sports/soccer/eng.1/scoreboard")!

    private var dismissedMatchID: String?
    private var timer: Timer?
    private var crestCache: [String: NSImage] = [:]

    init() {
        favoriteTeamID = UserDefaults.standard.string(forKey: Self.favoriteTeamKey)
    }

    func startPolling() {
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 45, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
    }

    func stopPolling() {
        timer?.invalidate()
        timer = nil
    }

    func dismissCurrentMatch() {
        guard let id = liveMatch?.id else { return }
        dismissedMatchID = id
        isDismissed = true
    }

    func undismissCurrentMatch() {
        dismissedMatchID = nil
        isDismissed = false
    }

    func crest(for teamID: String) -> NSImage? {
        if let cached = crestCache[teamID] { return cached }
        guard let url = URL(string: "https://a.espncdn.com/i/teamlogos/soccer/500/\(teamID).png") else { return nil }
        Task.detached(priority: .utility) { [weak self] in
            guard let self, let data = try? Data(contentsOf: url), let image = NSImage(data: data) else { return }
            await MainActor.run { self.crestCache[teamID] = image }
        }
        return nil
    }

    func refresh() {
        guard let favoriteTeamID else {
            liveMatch = nil
            isDismissed = false
            return
        }
        Task.detached(priority: .utility) { [weak self] in
            let match = await Self.fetchLiveMatch(favoriteTeamID: favoriteTeamID)
            await MainActor.run {
                guard let self else { return }
                self.liveMatch = match
                if match?.id != self.dismissedMatchID {
                    self.dismissedMatchID = nil
                }
                self.isDismissed = match != nil && match?.id == self.dismissedMatchID
            }
        }
    }

    nonisolated private static func fetchLiveMatch(favoriteTeamID: String) async -> LiveMatchInfo? {
        guard let (data, _) = try? await URLSession.shared.data(from: scoreboardURL) else { return nil }
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let events = json["events"] as? [[String: Any]] else { return nil }

        for event in events {
            guard let eventID = event["id"] as? String,
                  let competitions = event["competitions"] as? [[String: Any]],
                  let competition = competitions.first,
                  let status = competition["status"] as? [String: Any],
                  let statusType = status["type"] as? [String: Any],
                  let state = statusType["state"] as? String,
                  let competitors = competition["competitors"] as? [[String: Any]],
                  let home = competitors.first(where: { $0["homeAway"] as? String == "home" }),
                  let away = competitors.first(where: { $0["homeAway"] as? String == "away" }),
                  let homeTeam = home["team"] as? [String: Any],
                  let awayTeam = away["team"] as? [String: Any],
                  let homeTeamID = homeTeam["id"] as? String,
                  let awayTeamID = awayTeam["id"] as? String
            else { continue }

            guard homeTeamID == favoriteTeamID || awayTeamID == favoriteTeamID else { continue }
            guard state == "in" else { continue }

            let statusName = (statusType["name"] as? String) ?? ""
            let clock = statusName.contains("HALFTIME") ? "HT" : ((status["displayClock"] as? String) ?? "")

            return LiveMatchInfo(
                id: eventID,
                homeTeamID: homeTeamID,
                awayTeamID: awayTeamID,
                homeTeamName: (homeTeam["shortDisplayName"] as? String) ?? (homeTeam["displayName"] as? String) ?? "",
                awayTeamName: (awayTeam["shortDisplayName"] as? String) ?? (awayTeam["displayName"] as? String) ?? "",
                homeScore: Int((home["score"] as? String) ?? "") ?? 0,
                awayScore: Int((away["score"] as? String) ?? "") ?? 0,
                clockText: clock,
                favoriteIsHome: homeTeamID == favoriteTeamID
            )
        }
        return nil
    }
}
