import EventKit
import SwiftUI
import Combine

@MainActor
final class CalendarService: ObservableObject {
    @Published private(set) var todaysEvents: [CalendarEventInfo] = []
    @Published private(set) var authorizationDenied = false

    private let store = EKEventStore()
    private var timer: Timer?

    func requestAccessAndRefresh() {
        Task {
            do {
                let granted: Bool
                if #available(macOS 14.0, *) {
                    granted = try await store.requestFullAccessToEvents()
                } else {
                    granted = try await store.requestAccess(to: .event)
                }
                if granted {
                    refresh()
                    startPolling()
                } else {
                    authorizationDenied = true
                }
            } catch {
                authorizationDenied = true
            }
        }
    }

    func startPolling() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
    }

    func stopPolling() {
        timer?.invalidate()
        timer = nil
    }

    func refresh() {
        let calendar = Calendar.current
        let now = Date()
        guard let startOfDay = calendar.dateInterval(of: .day, for: now)?.start,
              let endOfDay = calendar.dateInterval(of: .day, for: now)?.end else { return }

        let predicate = store.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: nil)
        let events = store.events(matching: predicate)
            .sorted { $0.startDate < $1.startDate }
            .map { event in
                CalendarEventInfo(
                    id: event.eventIdentifier,
                    title: event.title ?? "Untitled",
                    startDate: event.startDate,
                    endDate: event.endDate,
                    isAllDay: event.isAllDay,
                    calendarColor: Color(nsColor: event.calendar.color)
                )
            }
        todaysEvents = events
    }
}
