import SwiftUI

struct StatsPanelView: View {
    @EnvironmentObject var service: SystemStatsService

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            statRow(
                title: "CPU",
                symbol: "cpu",
                fraction: service.cpuUsage,
                valueText: "\(Int(service.cpuUsage * 100))%"
            )
            statRow(
                title: "Memory",
                symbol: "memorychip",
                fraction: service.memoryUsedFraction,
                valueText: String(format: "%.1f / %.1f GB", service.memoryUsedGB, service.memoryTotalGB)
            )
            Spacer()
        }
    }

    private func statRow(title: String, symbol: String, fraction: Double, valueText: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label(title, systemImage: symbol)
                    .font(.system(size: 13, weight: .medium))
                Spacer()
                Text(valueText)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: min(max(fraction, 0), 1))
                .tint(fraction > 0.85 ? .red : .accentColor)
        }
    }
}
