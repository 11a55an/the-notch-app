import SwiftUI

struct NotchRootView: View {
    @EnvironmentObject var viewModel: NotchViewModel
    @EnvironmentObject var nowPlaying: NowPlayingService

    private var cornerRadius: CGFloat { 26 }

    var body: some View {
        ZStack {
            if viewModel.isExpanded {
                expandedPanel
            } else {
                collapsedPill
            }
        }
        .onHover { hovering in
            viewModel.setHovering(hovering)
        }
        .preferredColorScheme(.dark)
    }

    private var collapsedPill: some View {
        NotchShape(bottomCornerRadius: 12, topCornerRadius: 12)
            .fill(.black)
            .overlay(alignment: .trailing) {
                if nowPlaying.info.isPlaying {
                    Image(systemName: "waveform")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.white.opacity(0.85))
                        .symbolEffect(.variableColor.iterative, options: .repeating.speed(1.2))
                        .padding(.trailing, 10)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var expandedPanel: some View {
        VStack(spacing: 10) {
            NowPlayingView().environmentObject(viewModel.nowPlaying)

            HStack(spacing: 10) {
                CalendarPanelView().environmentObject(viewModel.calendar)
                StatsPanelView().environmentObject(viewModel.stats)
            }
            .frame(height: 190)

            ShelfPanelView().environmentObject(viewModel.shelf)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .padding(.top, viewModel.hasPhysicalNotch ? 34 : 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black, in: NotchShape(bottomCornerRadius: cornerRadius, topCornerRadius: 15, topEarWidth: 10))
        .clipShape(NotchShape(bottomCornerRadius: cornerRadius, topCornerRadius: 15, topEarWidth: 10))
    }
}
