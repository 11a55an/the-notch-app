import SwiftUI

struct MonthCalendarView: View {
    @EnvironmentObject var service: CalendarService

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)

    var body: some View {
        VStack(spacing: 3) {
            weekdayHeader
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(Array(daysInMonth().enumerated()), id: \.offset) { _, date in
                    if let date {
                        dayCell(date)
                    } else {
                        Color.clear.frame(height: 14)
                    }
                }
            }
        }
    }

    private var weekdayHeader: some View {
        HStack(spacing: 2) {
            ForEach(orderedWeekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.system(size: 8.5))
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var orderedWeekdaySymbols: [String] {
        let symbols = calendar.veryShortWeekdaySymbols
        let startIndex = calendar.firstWeekday - 1
        return Array(symbols[startIndex...] + symbols[..<startIndex])
    }

    private func dayCell(_ date: Date) -> some View {
        let isToday = calendar.isDateInToday(date)
        let day = calendar.component(.day, from: date)
        let hasEvents = service.monthEventDays.contains(
            calendar.dateComponents([.year, .month, .day], from: date)
        )

        return VStack(spacing: 0.5) {
            Text("\(day)")
                .font(.system(size: 9.5, weight: isToday ? .bold : .regular))
                .frame(width: 14, height: 14)
                .background(isToday ? Color.accentColor : .clear, in: Circle())
                .foregroundStyle(isToday ? .white : .primary)
            Circle()
                .fill(hasEvents && !isToday ? Color.accentColor : .clear)
                .frame(width: 2.5, height: 2.5)
        }
    }

    private func daysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: Date()) else { return [] }

        let firstWeekday = calendar.component(.weekday, from: monthInterval.start)
        let leadingEmptyDays = (firstWeekday - calendar.firstWeekday + 7) % 7

        var days: [Date?] = Array(repeating: nil, count: leadingEmptyDays)
        var date = monthInterval.start
        while date < monthInterval.end {
            days.append(date)
            date = calendar.date(byAdding: .day, value: 1, to: date) ?? monthInterval.end
        }
        return days
    }
}
