import AppKit
import SwiftUI

final class NotchWindowController: NSWindowController {
    private let viewModel = NotchViewModel()
    private var proximityMonitor: HoverProximityMonitor?

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

        viewModel.onExpandedChanged = { [weak self] expanded in
            self?.applyLayout(expanded: expanded, animated: true)
        }
    }

    func repositionForCurrentScreen() {
        applyLayout(expanded: viewModel.isExpanded, animated: false)
    }

    private func applyLayout(expanded: Bool, animated: Bool) {
        guard let window else { return }
        let geometry = NotchGeometry.current()
        let notchFrame = geometry.frameInScreen

        let expandedHeight = Self.expandedHeight + (geometry.hasPhysicalNotch ? 18 : 0)
        let width = expanded ? Self.expandedWidth : max(notchFrame.width, 180)
        let height = expanded ? expandedHeight : max(notchFrame.height, 32)

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
