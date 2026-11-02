import SwiftUI

struct NowPlayingView: View {
    @EnvironmentObject var service: NowPlayingService
    @State private var isDragging = false
    @State private var dragValue: Double = 0

    var body: some View {
        Group {
            if service.info.isActive {
                activeContent
            } else {
                emptyState
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 90)
        .background(Color.primary.opacity(0.045), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var activeContent: some View {
        HStack(spacing: 14) {
            artwork
            VStack(alignment: .leading, spacing: 3) {
                Text(service.info.title)
                    .font(.system(size: 14.5, weight: .semibold))
                    .lineLimit(1)
                    .contentTransition(.opacity)
                if !service.info.artist.isEmpty {
                    Text(service.info.artist)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .contentTransition(.opacity)
                }
            }
            .frame(width: 130, alignment: .leading)

            controls

            progressColumn
        }
        .animation(.easeInOut(duration: 0.25), value: service.info.title)
    }

    private var artwork: some View {
        Group {
            if let image = service.info.artwork {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .transition(.opacity)
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.quaternary)
                    .overlay(Image(systemName: service.info.source.symbolName).foregroundStyle(.secondary))
            }
        }
        .frame(width: 60, height: 60)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(alignment: .bottomTrailing) {
            sourceBadge
                .offset(x: 4, y: 4)
        }
        .shadow(color: .black.opacity(0.25), radius: 6, y: 3)
    }

    private var sourceBadge: some View {
        Image(systemName: service.info.source == .chrome ? "globe" : "music.note")
            .font(.system(size: 7, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: 14, height: 14)
            .background(sourceBadgeColor, in: Circle())
            .overlay(Circle().strokeBorder(.black.opacity(0.4), lineWidth: 1))
    }

    private var sourceBadgeColor: Color {
        switch service.info.source {
        case .spotify: return Color(red: 0.11, green: 0.73, blue: 0.33)
        case .music: return Color(red: 0.98, green: 0.24, blue: 0.35)
        case .chrome: return Color(red: 0.26, green: 0.52, blue: 0.96)
        case .none: return .gray
        }
    }

    private var controls: some View {
        HStack(spacing: 16) {
            if service.info.source.supportsTrackSkipping {
                playbackButton("backward.fill", size: 12, action: service.previous)
            }
            playbackButton(
                service.info.isPlaying ? "pause.fill" : "play.fill",
                size: 14,
                prominent: true,
                action: service.togglePlayPause
            )
            if service.info.source.supportsTrackSkipping {
                playbackButton("forward.fill", size: 12, action: service.next)
            }
        }
    }

    private func playbackButton(_ symbol: String, size: CGFloat, prominent: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: size, weight: .semibold))
                .frame(width: prominent ? 28 : 24, height: prominent ? 28 : 24)
                .background(prominent ? Color.primary.opacity(0.12) : .clear, in: Circle())
        }
        .buttonStyle(.pressable)
        .foregroundStyle(.primary)
    }

    private var progressColumn: some View {
        let duration = max(service.info.durationSeconds, 1)
        let displayedElapsed = isDragging ? dragValue : service.info.elapsedSeconds

        return VStack(alignment: .trailing, spacing: 4) {
            Slider(
                value: Binding(
                    get: { displayedElapsed },
                    set: { newValue in
                        isDragging = true
                        dragValue = newValue
                    }
                ),
                in: 0...duration,
                onEditingChanged: { editing in
                    if !editing {
                        service.seek(to: dragValue)
                        isDragging = false
                    }
                }
            )
            .controlSize(.mini)

            Text("\(timeString(displayedElapsed)) / \(timeString(duration))")
                .font(.system(size: 10.5))
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
        .frame(minWidth: 120, maxWidth: 160)
    }

    private func timeString(_ seconds: Double) -> String {
        let total = max(Int(seconds), 0)
        return String(format: "%d:%02d", total / 60, total % 60)
    }

    private var emptyState: some View {
        HStack(spacing: 8) {
            Image(systemName: "speaker.slash")
                .foregroundStyle(.secondary)
            Text("Nothing playing")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
