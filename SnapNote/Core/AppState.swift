import Foundation
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var isWatching = true
    @Published var latestScreenshot: ScreenshotItem?
    @Published var draftText = ""
    @Published var lastSavedNoteURL: URL?
    @Published var statusMessage = "Watching Desktop for new screenshots…"

    var onPresentNote: ((ScreenshotItem) -> Void)?

    private let watcher = ScreenshotWatcher()

    init() {
        watcher.onScreenshotDetected = { [weak self] item in
            Task { @MainActor in
                self?.handleScreenshot(item)
            }
        }
        watcher.start()
    }

    func setWatching(_ enabled: Bool) {
        isWatching = enabled
        if enabled {
            watcher.start()
            statusMessage = "Watching Desktop for new screenshots…"
        } else {
            watcher.stop()
            statusMessage = "Paused"
        }
    }

    func checkNow() {
        watcher.scanNow()
    }

    func saveNote(for item: ScreenshotItem) {
        let noteURL = item.url.deletingPathExtension().appendingPathExtension("note.md")
        let body = """
        # Screenshot Note

        - image: \(item.url.lastPathComponent)
        - capturedAt: \(item.createdAt.formatted(date: .abbreviated, time: .standard))

        ## Context

        \(draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "(empty)" : draftText)
        """

        do {
            try body.write(to: noteURL, atomically: true, encoding: .utf8)
            lastSavedNoteURL = noteURL
            statusMessage = "Saved note: \(noteURL.lastPathComponent)"
        } catch {
            statusMessage = "Save failed: \(error.localizedDescription)"
        }
    }

    private func handleScreenshot(_ item: ScreenshotItem) {
        latestScreenshot = item
        draftText = ""
        statusMessage = "New screenshot: \(item.url.lastPathComponent)"
        onPresentNote?(item)
    }
}
