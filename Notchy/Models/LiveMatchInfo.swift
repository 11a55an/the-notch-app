import Foundation

struct PremierLeagueTeam: Identifiable, Hashable {
    let id: String
    let name: String
}

enum EPLTeams {
    static let all: [PremierLeagueTeam] = [
        .init(id: "349", name: "AFC Bournemouth"),
        .init(id: "359", name: "Arsenal"),
        .init(id: "362", name: "Aston Villa"),
        .init(id: "337", name: "Brentford"),
        .init(id: "331", name: "Brighton & Hove Albion"),
        .init(id: "363", name: "Chelsea"),
        .init(id: "388", name: "Coventry City"),
        .init(id: "384", name: "Crystal Palace"),
        .init(id: "368", name: "Everton"),
        .init(id: "370", name: "Fulham"),
        .init(id: "306", name: "Hull City"),
        .init(id: "373", name: "Ipswich Town"),
        .init(id: "357", name: "Leeds United"),
        .init(id: "364", name: "Liverpool"),
        .init(id: "382", name: "Manchester City"),
        .init(id: "360", name: "Manchester United"),
        .init(id: "361", name: "Newcastle United"),
        .init(id: "393", name: "Nottingham Forest"),
        .init(id: "366", name: "Sunderland"),
        .init(id: "367", name: "Tottenham Hotspur"),
    ]

    static func name(for id: String) -> String? {
        all.first { $0.id == id }?.name
    }
}

struct LiveMatchInfo: Equatable, Identifiable {
    var id: String
    var homeTeamID: String
    var awayTeamID: String
    var homeTeamName: String
    var awayTeamName: String
    var homeScore: Int
    var awayScore: Int
    var clockText: String
    var favoriteIsHome: Bool

    var favoriteScore: Int { favoriteIsHome ? homeScore : awayScore }
    var opponentScore: Int { favoriteIsHome ? awayScore : homeScore }
    var opponentName: String { favoriteIsHome ? awayTeamName : homeTeamName }
}
