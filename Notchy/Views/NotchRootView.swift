import SwiftUI

struct NotchRootView: View {
    @EnvironmentObject var viewModel: NotchViewModel

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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var expandedPanel: some View {
        VStack(spacing: 10) {
            NowPlayingView().environmentObject(viewModel.nowPlaying)

            HStack(spacing: 10) {
                CalendarPanelView().environmentObject(viewModel.calendar)
                StatsPanelView().environmentObject(viewModel.stats)
            }
            .frame(height: 148)

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
