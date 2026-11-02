import SwiftUI
import UniformTypeIdentifiers

struct NotchRootView: View {
    @EnvironmentObject var viewModel: NotchViewModel
    @EnvironmentObject var nowPlaying: NowPlayingService
    @EnvironmentObject var premierLeague: PremierLeagueScoreService
    @State private var liveDotPulse = false

    private var cornerRadius: CGFloat { 26 }

    private var showScorePill: Bool {
        premierLeague.liveMatch != nil && !premierLeague.isDismissed
    }

    var body: some View {
        ZStack {
            if viewModel.isExpanded {
                expandedPanel
            } else if showScorePill, let match = premierLeague.liveMatch {
                scorePill(match)
            } else if nowPlaying.info.isPlaying {
                musicActivityPill
            } else {
                collapsedPill
            }
        }
        .onHover { hovering in
            // Window resizes (e.g. the music-activity pill growing/shrinking on
            // playback changes) can fire synthetic enter/exit events here even
            // though the cursor never moved. Only trust a "true" signal once
            // already expanded (keeps the panel open while interacting with it);
            // the real expand trigger is HoverProximityMonitor, which reacts
            // solely to genuine mouse movement near the fixed notch geometry.
            if hovering {
                if viewModel.isExpanded {
                    viewModel.setHovering(true)
                }
            } else {
                viewModel.setHovering(false)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var collapsedPill: some View {
        NotchShape(bottomCornerRadius: 12, topCornerRadius: 12)
            .fill(.black)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var musicActivityPill: some View {
        let info = nowPlaying.info
        return HStack(spacing: 0) {
            activityLeading(info)
            Spacer(minLength: 0)
            activityTrailing(info)
        }
        .padding(.horizontal, NotchLiveActivityMetrics.horizontalPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color.black,
            in: NotchShape(
                bottomCornerRadius: NotchLiveActivityMetrics.bottomCornerRadius,
                topCornerRadius: NotchLiveActivityMetrics.topCornerRadius,
                topEarWidth: NotchLiveActivityMetrics.topEarWidth
            )
        )
        .clipShape(
            NotchShape(
                bottomCornerRadius: NotchLiveActivityMetrics.bottomCornerRadius,
                topCornerRadius: NotchLiveActivityMetrics.topCornerRadius,
                topEarWidth: NotchLiveActivityMetrics.topEarWidth
            )
        )
        .transition(.opacity.combined(with: .scale(scale: 0.92, anchor: .top)))
    }

    private func activityLeading(_ info: NowPlayingInfo) -> some View {
        activityArtwork(info)
            .frame(width: NotchLiveActivityMetrics.sideContentWidth, alignment: .leading)
    }

    private func activityArtwork(_ info: NowPlayingInfo) -> some View {
        Group {
            if let image = info.artwork {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .transition(.opacity)
            } else {
                RoundedRectangle(cornerRadius: 6)
                    .fill(.quaternary)
                    .overlay(
                        Image(systemName: info.source.symbolName)
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                    )
            }
        }
        .frame(width: 24, height: 24)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private func activityTrailing(_ info: NowPlayingInfo) -> some View {
        HStack {
            Image(systemName: "waveform")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.white.opacity(0.85))
                .symbolEffect(.variableColor.iterative, options: .repeating.speed(1.2))
        }
        .frame(width: NotchLiveActivityMetrics.sideContentWidth, alignment: .trailing)
    }

    private func scorePill(_ match: LiveMatchInfo) -> some View {
        HStack(spacing: 0) {
            scoreLeadingSide(teamID: match.favoriteIsHome ? match.homeTeamID : match.awayTeamID, score: match.favoriteScore)
            Spacer(minLength: 0)
            scoreTrailingSide(teamID: match.favoriteIsHome ? match.awayTeamID : match.homeTeamID, score: match.opponentScore, clockText: match.clockText)
        }
        .padding(.horizontal, NotchLiveActivityMetrics.horizontalPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color.black,
            in: NotchShape(
                bottomCornerRadius: NotchLiveActivityMetrics.bottomCornerRadius,
                topCornerRadius: NotchLiveActivityMetrics.topCornerRadius,
                topEarWidth: NotchLiveActivityMetrics.topEarWidth
            )
        )
        .clipShape(
            NotchShape(
                bottomCornerRadius: NotchLiveActivityMetrics.bottomCornerRadius,
                topCornerRadius: NotchLiveActivityMetrics.topCornerRadius,
                topEarWidth: NotchLiveActivityMetrics.topEarWidth
            )
        )
        .transition(.opacity.combined(with: .scale(scale: 0.92, anchor: .top)))
    }

    private func scoreLeadingSide(teamID: String, score: Int) -> some View {
        HStack(spacing: 5) {
            liveDot
            crestImage(teamID: teamID)
            Text("\(score)")
                .font(.system(size: 13, weight: .bold))
                .monospacedDigit()
        }
        .frame(width: NotchLiveActivityMetrics.scoreSideContentWidth, alignment: .leading)
    }

    private func scoreTrailingSide(teamID: String, score: Int, clockText: String) -> some View {
        HStack(spacing: 5) {
            Text("\(score)")
                .font(.system(size: 13, weight: .bold))
                .monospacedDigit()
            crestImage(teamID: teamID)
            Text(clockText)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)
                .monospacedDigit()
                .lineLimit(1)
        }
        .frame(width: NotchLiveActivityMetrics.scoreSideContentWidth, alignment: .trailing)
    }

    private var liveDot: some View {
        Circle()
            .fill(Color.green)
            .frame(width: 6, height: 6)
            .opacity(liveDotPulse ? 1 : 0.4)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                    liveDotPulse = true
                }
            }
    }

    private func crestImage(teamID: String) -> some View {
        Group {
            if let image = premierLeague.crest(for: teamID) {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Circle().fill(.quaternary)
            }
        }
        .frame(width: 18, height: 18)
    }

    private var liveScoreBanner: some View {
        Group {
            if let match = premierLeague.liveMatch {
                HStack(spacing: 10) {
                    HStack(spacing: 6) {
                        crestImage(teamID: match.homeTeamID)
                        Text(match.homeTeamName).font(.system(size: 12, weight: .medium)).lineLimit(1)
                    }
                    Text("\(match.homeScore) - \(match.awayScore)")
                        .font(.system(size: 13, weight: .bold))
                        .monospacedDigit()
                    HStack(spacing: 6) {
                        Text(match.awayTeamName).font(.system(size: 12, weight: .medium)).lineLimit(1)
                        crestImage(teamID: match.awayTeamID)
                    }
                    HStack(spacing: 5) {
                        liveDot
                        Text(match.clockText)
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                    Spacer(minLength: 0)
                    Button(action: { premierLeague.dismissCurrentMatch() }) {
                        Image(systemName: "eye.slash")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.pressable)
                }
                .padding(.horizontal, 14)
                .frame(height: 36)
                .background(Color.primary.opacity(0.045), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }

    private var expandedPanel: some View {
        VStack(spacing: 10) {
            if premierLeague.liveMatch != nil {
                liveScoreBanner
            }

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
        .onDrop(of: [.fileURL], isTargeted: nil) { providers in
            viewModel.shelf.handleDrop(providers)
            return true
        }
    }
}
