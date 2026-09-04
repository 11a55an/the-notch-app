import SwiftUI

struct NotchRootView: View {
    @EnvironmentObject var viewModel: NotchViewModel

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
    }

    private var collapsedPill: some View {
        NotchShape(bottomCornerRadius: 12)
            .fill(.black)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var expandedPanel: some View {
        VStack(spacing: 0) {
            tabBar
            Divider().opacity(0.2)
            selectedTabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black.opacity(0.001))
        .background(.regularMaterial, in: NotchShape(bottomCornerRadius: 24))
        .clipShape(NotchShape(bottomCornerRadius: 24))
        .overlay(
            NotchShape(bottomCornerRadius: 24)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
    }

    private var tabBar: some View {
        HStack(spacing: 4) {
            ForEach(NotchTab.allCases) { tab in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                        viewModel.selectedTab = tab
                    }
                } label: {
                    Label(tab.rawValue, systemImage: tab.symbolName)
                        .labelStyle(.iconOnly)
                        .font(.system(size: 14, weight: .medium))
                        .frame(width: 32, height: 24)
                        .background(
                            viewModel.selectedTab == tab ? Color.accentColor.opacity(0.25) : .clear,
                            in: RoundedRectangle(cornerRadius: 8)
                        )
                }
                .buttonStyle(.plain)
                .foregroundStyle(viewModel.selectedTab == tab ? Color.accentColor : .secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private var selectedTabContent: some View {
        switch viewModel.selectedTab {
        case .nowPlaying:
            NowPlayingView().environmentObject(viewModel.nowPlaying)
        case .calendar:
            CalendarPanelView().environmentObject(viewModel.calendar)
        case .stats:
            StatsPanelView().environmentObject(viewModel.stats)
        case .shelf:
            ShelfPanelView().environmentObject(viewModel.shelf)
        }
    }
}
