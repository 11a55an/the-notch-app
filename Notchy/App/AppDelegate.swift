import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var notchWindowController: NotchWindowController?
    private var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let controller = NotchWindowController()
        notchWindowController = controller
        controller.show()

        setUpStatusItem()

        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(screensChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }

    @objc private func screensChanged() {
        notchWindowController?.repositionForCurrentScreen()
    }

    private func setUpStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        item.button?.image = NSImage(systemSymbolName: "rectangle.topthird.inset.filled", accessibilityDescription: "Notchy")

        let menu = NSMenu()
        menu.addItem(withTitle: "About Notchy", action: #selector(showAbout), keyEquivalent: "")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit Notchy", action: #selector(quit), keyEquivalent: "q")
        for menuItem in menu.items {
            menuItem.target = self
        }
        item.menu = menu
        statusItem = item
    }

    @objc private func showAbout() {
        NSApp.orderFrontStandardAboutPanel(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
