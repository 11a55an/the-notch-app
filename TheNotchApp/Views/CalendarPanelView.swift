import SwiftUI

private enum CalendarDisplayMode {
    case month
    case events
}

struct CalendarPanelView: View {
    @EnvironmentObject var service: CalendarService
    @State private var displayMode: CalendarDisplayMode = .month

    var body: some View {
        DashboardCard(title: "Calendar", symbolName: "calendar", content: {
            Group {
                if service.authorizationDenied {
                    message("Calendar access denied", symbol: "calendar.badge.exclamationmark")
                } else {
                    switch displayMode {
                    case .month:
                        MonthCalendarView().environmentObject(service)
                    case .events:
                        eventsList
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }, accessory: {
            if !service.authorizationDenied {
                modeToggle
            }
        })
    }

    private var modeToggle: some View {
        HStack(spacing: 2) {
            toggleButton(symbol: "calendar", mode: .month)
            toggleButton(symbol: "list.bullet", mode: .events)
        }
        .padding(2)
        .background(Color.primary.opacity(0.06), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
    }

    private func toggleButton(symbol: String, mode: CalendarDisplayMode) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                displayMode = mode
            }
        } label: {
            Image(systemName: symbol)
                .font(.system(size: 9.5, weight: .semibold))
                .frame(width: 20, height: 16)
                .background(
                    displayMode == mode ? Color.accentColor.opacity(0.3) : .clear,
                    in: RoundedRectangle(cornerRadius: 5, style: .continuous)
                )
        }
        .buttonStyle(.pressable)
        .foregroundStyle(displayMode == mode ? Color.accentColor : .secondary)
    }

    private var eventsList: some View {
        Group {
            if service.todaysEvents.isEmpty {
                message("No events today", symbol: "calendar")
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(service.todaysEvents) { event in
                            eventRow(event)
                        }
                    }
                }
            }
        }
    }

    private func eventRow(_ event: CalendarEventInfo) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(event.calendarColor)
                .frame(width: 7, height: 7)
            VStack(alignment: .leading, spacing: 1) {
                Text(event.title)
                    .font(.system(size: 12.5, weight: .medium))
                    .strikethrough(event.hasEnded)
                    .lineLimit(1)
                Text(event.timeRangeText)
                    .font(.system(size: 10.5))
                    .foregroundStyle(.secondary)
            }
        }
        .opacity(event.hasEnded ? 0.5 : 1)
    }

    private func message(_ text: String, symbol: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: symbol).foregroundStyle(.secondary)
            Text(text).font(.system(size: 12.5)).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}
