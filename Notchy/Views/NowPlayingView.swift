import SwiftUI

struct NowPlayingView: View {
    @EnvironmentObject var service: NowPlayingService

    var body: some View {
        if service.info.isActive {
            HStack(spacing: 16) {
                artwork
                VStack(alignment: .leading, spacing: 4) {
                    Text(service.info.title)
                        .font(.system(size: 15, weight: .semibold))
                        .lineLimit(1)
                    if !service.info.artist.isEmpty {
                        Text(service.info.artist)
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    Spacer()
                    controls
                }
            }
        } else {
            emptyState
        }
    }

    private var artwork: some View {
        Group {
            if let image = service.info.artwork {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.quaternary)
                    .overlay(Image(systemName: "music.note").foregroundStyle(.secondary))
            }
        }
        .frame(width: 88, height: 88)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var controls: some View {
        HStack(spacing: 20) {
            if service.info.source.supportsTrackSkipping {
                Button(action: service.previous) {
                    Image(systemName: "backward.fill")
                }
            }
            Button(action: service.togglePlayPause) {
                Image(systemName: service.info.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 18))
            }
            if service.info.source.supportsTrackSkipping {
                Button(action: service.next) {
                    Image(systemName: "forward.fill")
                }
            }
        }
        .buttonStyle(.plain)
        .font(.system(size: 14))
        .foregroundStyle(.primary)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "speaker.slash")
                .font(.system(size: 22))
                .foregroundStyle(.secondary)
            Text("Nothing playing")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
