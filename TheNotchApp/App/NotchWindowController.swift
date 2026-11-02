import AppKit
import SwiftUI
import Combine

final class NotchWindowController: NSWindowController {
    private let viewModel = NotchViewModel()
    private var proximityMonitor: HoverProximityMonitor?
    private var cancellables = Set<AnyCancellable>()

    var premierLeague: PremierLeagueScoreService { viewModel.premierLeague }

    private static let expandedWidth: CGFloat = 600
    private static let expandedHeight: CGFloat = 414

    convenience init() {
        let panel = NotchPanel(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.maximumWindow)))
        panel.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary, .ignoresCycle]
        panel.isMovable = false
        panel.hidesOnDeactivate = false
        panel.ignoresMouseEvents = false

        self.init(window: panel)

        let hosting = NSHostingView(
            rootView: NotchRootView()
                .environmentObject(viewModel)
                .environmentObject(viewModel.nowPlaying)
                .environmentObject(viewModel.premierLeague)
        )
        hosting.frame = .zero
        panel.contentView = hosting
    }

    func show() {
        repositionForCurrentScreen()
        window?.orderFrontRegardless()

        let monitor = HoverProximityMonitor(geometryProvider: { NotchGeometry.current() }) { [weak self] isNear in
            self?.viewModel.setHovering(isNear)
        }
        monitor.start()
        proximityMonitor = monitor

        let hasLiveMatch = viewModel.premierLeague.$liveMatch.map { $0 != nil }.removeDuplicates()
        let showScore = viewModel.premierLeague.$liveMatch
            .combineLatest(viewModel.premierLeague.$isDismissed)
            .map { match, dismissed in match != nil && !dismissed }
            .removeDuplicates()

        Publishers.CombineLatest4(
            viewModel.$isExpanded,
            viewModel.nowPlaying.$info.map(\.isPlaying).removeDuplicates(),
            showScore,
            hasLiveMatch
        )
        .removeDuplicates(by: { $0 == $1 })
        .dropFirst()
        .sink { [weak self] expanded, playing, score, hasMatch in
            self?.applyLayout(expanded: expanded, playing: playing, showScore: score, hasLiveMatch: hasMatch, animated: true)
        }
        .store(in: &cancellables)
    }

    func repositionForCurrentScreen() {
        let showScore = viewModel.premierLeague.liveMatch != nil && !viewModel.premierLeague.isDismissed
        applyLayout(
            expanded: viewModel.isExpanded,
            playing: viewModel.nowPlaying.info.isPlaying,
            showScore: showScore,
            hasLiveMatch: viewModel.premierLeague.liveMatch != nil,
            animated: false
        )
    }

    private func applyLayout(expanded: Bool, playing: Bool, showScore: Bool, hasLiveMatch: Bool, animated: Bool) {
        guard let window else { return }
        let geometry = NotchGeometry.current()
        let notchFrame = geometry.frameInScreen
        let scoreActive = !expanded && showScore
        let musicActive = !expanded && !scoreActive && playing

        let expandedHeight = Self.expandedHeight + (geometry.hasPhysicalNotch ? 18 : 0) + (hasLiveMatch ? 46 : 0)
        let width: CGFloat
        let height: CGFloat
        if expanded {
            width = Self.expandedWidth
            height = expandedHeight
        } else if scoreActive {
            let sideWidth = NotchLiveActivityMetrics.scoreSideContentWidth + NotchLiveActivityMetrics.horizontalPadding
            width = notchFrame.width + sideWidth * 2
            height = max(notchFrame.height, 32) + NotchLiveActivityMetrics.extraHeight
        } else if musicActive {
            let sideWidth = NotchLiveActivityMetrics.sideContentWidth + NotchLiveActivityMetrics.horizontalPadding
            width = notchFrame.width + sideWidth * 2
            height = max(notchFrame.height, 32) + NotchLiveActivityMetrics.extraHeight
        } else {
            width = max(notchFrame.width, 180)
            height = max(notchFrame.height, 32)
        }

        let x = notchFrame.midX - width / 2
        let y = notchFrame.maxY - height
        let newFrame = CGRect(x: x, y: y, width: width, height: height)

        if animated {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.32
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                window.animator().setFrame(newFrame, display: true)
            } completionHandler: {
                Task { @MainActor in window.invalidateShadow() }
            }
        } else {
            window.setFrame(newFrame, display: true)
            window.invalidateShadow()
        }
    }
}

final class NotchPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}
