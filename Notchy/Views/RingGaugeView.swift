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
                    .stroke(
                        AngularGradient(
                            colors: [color.opacity(0.5), color],
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360 * fraction)
                        ),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.4), value: fraction)
                Text("\(Int(fraction * 100))%")
                    .font(.system(size: 14, weight: .bold))
                    .monospacedDigit()
                    .contentTransition(.numericText())
            }
            .frame(width: 62, height: 62)

            Text(label)
                .font(.system(size: 11.5))
                .foregroundStyle(.secondary)
        }
    }
}
