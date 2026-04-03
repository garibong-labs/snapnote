import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var notePanel: NSPanel?
    private weak var appState: AppState?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        configureStatusItem()
    }

    func configure(with appState: AppState) {
        guard self.appState !== appState else { return }
        self.appState = appState
        appState.onPresentNote = { [weak self] item in
            self?.showNotePanel(for: item)
        }
    }

    private func configureStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.title = "✍︎"
        item.button?.toolTip = "SnapNote"

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Open Dashboard", action: #selector(openDashboard), keyEquivalent: "o"))
        menu.addItem(NSMenuItem(title: "Check Desktop Now", action: #selector(checkNow), keyEquivalent: "r"))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))
        item.menu = menu
        statusItem = item
    }

    @objc private func openDashboard() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.windows.first?.makeKeyAndOrderFront(nil)
    }

    @objc private func checkNow() {
        appState?.checkNow()
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }

    private func showNotePanel(for item: ScreenshotItem) {
        if let panel = notePanel {
            panel.contentView = NSHostingView(rootView: NotePanelView(item: item).environmentObject(appState ?? AppState()))
            NSApp.activate(ignoringOtherApps: true)
            panel.makeKeyAndOrderFront(nil)
            return
        }

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 520, height: 520),
            styleMask: [.titled, .closable, .utilityWindow, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        panel.title = "New Screenshot Note"
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.center()
        panel.collectionBehavior = [.moveToActiveSpace]
        panel.contentView = NSHostingView(rootView: NotePanelView(item: item).environmentObject(appState ?? AppState()))
        notePanel = panel

        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
    }
}
