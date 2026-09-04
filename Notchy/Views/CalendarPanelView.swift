import SwiftUI

struct CalendarPanelView: View {
    @EnvironmentObject var service: CalendarService

    var body: some View {
        if service.authorizationDenied {
            VStack(spacing: 8) {
                Image(systemName: "calendar.badge.exclamationmark")
                    .font(.system(size: 22))
                    .foregroundStyle(.secondary)
                Text("Calendar access denied")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if service.todaysEvents.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.system(size: 22))
                    .foregroundStyle(.secondary)
                Text("No events today")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(service.todaysEvents) { event in
                        eventRow(event)
                    }
                }
            }
        }
    }

    private func eventRow(_ event: CalendarEventInfo) -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(event.calendarColor)
                .frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.system(size: 13, weight: .medium))
                    .strikethrough(event.hasEnded)
                    .lineLimit(1)
                Text(event.timeRangeText)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .opacity(event.hasEnded ? 0.5 : 1)
    }
}
