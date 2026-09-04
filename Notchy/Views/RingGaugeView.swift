import SwiftUI

struct RingGaugeView: View {
    let fraction: Double
    let color: Color
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .stroke(Color.primary.opacity(0.1), lineWidth: 6)
                Circle()
                    .trim(from: 0, to: min(max(fraction, 0), 1))
                    .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(Int(fraction * 100))%")
                    .font(.system(size: 14, weight: .bold))
            }
            .frame(width: 62, height: 62)

            Text(label)
                .font(.system(size: 11.5))
                .foregroundStyle(.secondary)
        }
    }
}
