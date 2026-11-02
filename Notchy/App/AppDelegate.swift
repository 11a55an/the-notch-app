import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private var notchWindowController: NotchWindowController?
    private var statusItem: NSStatusItem?
    private var hideScoreItem: NSMenuItem?
    private var teamMenuItems: [NSMenuItem] = []

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
        item.button?.image = NSImage(systemSymbolName: "rectangle.topthird.inset.filled", accessibilityDescription: "The Notch App")

        let menu = NSMenu()
        menu.delegate = self
        menu.addItem(withTitle: "About The Notch App", action: #selector(showAbout), keyEquivalent: "")
        menu.addItem(.separator())

        let teamMenu = NSMenu()
        teamMenuItems = EPLTeams.all.map { team in
            let menuItem = NSMenuItem(title: team.name, action: #selector(selectFavoriteTeam(_:)), keyEquivalent: "")
            menuItem.representedObject = team.id
            menuItem.target = self
            teamMenu.addItem(menuItem)
            return menuItem
        }
        let teamItem = NSMenuItem(title: "Favorite Premier League Team", action: nil, keyEquivalent: "")
        teamItem.submenu = teamMenu
        menu.addItem(teamItem)

        let hideItem = NSMenuItem(title: "Hide Live Score", action: #selector(toggleHideLiveScore), keyEquivalent: "")
        hideItem.target = self
        hideScoreItem = hideItem
        menu.addItem(hideItem)

        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit The Notch App", action: #selector(quit), keyEquivalent: "q")
        for menuItem in menu.items where menuItem.action != nil {
            menuItem.target = menuItem.target ?? self
        }
        item.menu = menu
        statusItem = item
    }

    func menuWillOpen(_ menu: NSMenu) {
        guard let premierLeague = notchWindowController?.premierLeague else { return }
        for menuItem in teamMenuItems {
            menuItem.state = (menuItem.representedObject as? String) == premierLeague.favoriteTeamID ? .on : .off
        }

        let hasLiveMatch = premierLeague.liveMatch != nil
        hideScoreItem?.isHidden = !hasLiveMatch
        hideScoreItem?.title = premierLeague.isDismissed ? "Show Live Score" : "Hide Live Score"
    }

    @objc private func selectFavoriteTeam(_ sender: NSMenuItem) {
        notchWindowController?.premierLeague.favoriteTeamID = sender.representedObject as? String
    }

    @objc private func toggleHideLiveScore() {
        guard let premierLeague = notchWindowController?.premierLeague else { return }
        if premierLeague.isDismissed {
            premierLeague.undismissCurrentMatch()
        } else {
            premierLeague.dismissCurrentMatch()
        }
    }

    @objc private func showAbout() {
        NSApp.orderFrontStandardAboutPanel(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
