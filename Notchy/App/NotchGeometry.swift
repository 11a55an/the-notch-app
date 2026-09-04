import AppKit

struct NotchGeometry {
    let screen: NSScreen
    let notchWidth: CGFloat
    let notchHeight: CGFloat
    let hasPhysicalNotch: Bool

    var frameInScreen: CGRect {
        let screenFrame = screen.frame
        let x = screenFrame.midX - notchWidth / 2
        let y = screenFrame.maxY - notchHeight
        return CGRect(x: x, y: y, width: notchWidth, height: notchHeight)
    }

    static func current() -> NotchGeometry {
        let notchedScreen = NSScreen.screens.first { $0.safeAreaInsets.top > 0 } ?? NSScreen.main
        guard let screen = notchedScreen else {
            let fallback = NSScreen.screens.first!
            return NotchGeometry(screen: fallback, notchWidth: 200, notchHeight: 32, hasPhysicalNotch: false)
        }

        if screen.safeAreaInsets.top > 0 {
            let height = screen.safeAreaInsets.top
            var width: CGFloat = 200
            if let leftArea = screen.auxiliaryTopLeftArea, let rightArea = screen.auxiliaryTopRightArea {
                width = screen.frame.width - leftArea.width - rightArea.width
            }
            return NotchGeometry(screen: screen, notchWidth: width, notchHeight: height, hasPhysicalNotch: true)
        } else {
            let menuBarHeight = screen.frame.height - screen.visibleFrame.height - (screen.visibleFrame.minY - screen.frame.minY)
            let height = max(menuBarHeight, 24)
            return NotchGeometry(screen: screen, notchWidth: 220, notchHeight: height, hasPhysicalNotch: false)
        }
    }
}
