import SwiftUI

struct CalendarEventInfo: Identifiable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let isAllDay: Bool
    let calendarColor: Color

    var timeRangeText: String {
        if isAllDay { return "All-day" }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return "\(formatter.string(from: startDate)) – \(formatter.string(from: endDate))"
    }

    var hasStarted: Bool { startDate <= Date() }
    var hasEnded: Bool { endDate <= Date() }
}
