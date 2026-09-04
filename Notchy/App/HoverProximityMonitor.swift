import AppKit

final class HoverProximityMonitor {
    private let geometryProvider: () -> NotchGeometry
    private let onProximityChanged: (Bool) -> Void

    private var globalMonitor: Any?
    private var localMonitor: Any?
    private var isCurrentlyNear = false

    private let expandTriggerDistance: CGFloat = 6
    private let collapseTriggerDistance: CGFloat = 140

    init(geometryProvider: @escaping () -> NotchGeometry, onProximityChanged: @escaping (Bool) -> Void) {
        self.geometryProvider = geometryProvider
        self.onProximityChanged = onProximityChanged
    }

    func start() {
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved]) { [weak self] _ in
            self?.handleMouseMoved()
        }
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) { [weak self] event in
            self?.handleMouseMoved()
            return event
        }
    }

    func stop() {
        if let globalMonitor { NSEvent.removeMonitor(globalMonitor) }
        if let localMonitor { NSEvent.removeMonitor(localMonitor) }
        globalMonitor = nil
        localMonitor = nil
    }

    private func handleMouseMoved() {
        let mouseLocation = NSEvent.mouseLocation
        let notchFrame = geometryProvider().frameInScreen

        let activeDistance = isCurrentlyNear ? collapseTriggerDistance : expandTriggerDistance
        let triggerZone = notchFrame
            .insetBy(dx: -activeDistance, dy: 0)
            .union(notchFrame.insetBy(dx: -activeDistance, dy: 0).offsetBy(dx: 0, dy: -activeDistance))

        let near = triggerZone.contains(mouseLocation)
        guard near != isCurrentlyNear else { return }
        isCurrentlyNear = near
        onProximityChanged(near)
    }

    deinit {
        stop()
    }
}
