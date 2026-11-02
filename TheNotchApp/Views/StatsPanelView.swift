import SwiftUI

struct StatsPanelView: View {
    @EnvironmentObject var service: SystemStatsService

    var body: some View {
        DashboardCard(title: "CPU & Memory", symbolName: "chart.bar.fill") {
            HStack(spacing: 20) {
                RingGaugeView(fraction: service.cpuUsage, color: .blue, label: "CPU")
                RingGaugeView(fraction: service.memoryUsedFraction, color: .purple, label: "Memory")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
}
