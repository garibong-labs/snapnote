import SwiftUI

struct MainView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("SnapNote")
                .font(.largeTitle.weight(.semibold))

            Text("Tiny macOS helper that watches your Desktop, catches fresh screenshots, and opens a note window before context disappears.")
                .foregroundStyle(.secondary)

            Toggle("Watch Desktop for new screenshots", isOn: Binding(
                get: { appState.isWatching },
                set: { appState.setWatching($0) }
            ))

            GroupBox("Status") {
                VStack(alignment: .leading, spacing: 8) {
                    LabeledContent("Watcher", value: appState.isWatching ? "Active" : "Paused")
                    LabeledContent("Message", value: appState.statusMessage)
                    if let latest = appState.latestScreenshot {
                        LabeledContent("Latest", value: latest.url.lastPathComponent)
                    }
                    if let saved = appState.lastSavedNoteURL {
                        LabeledContent("Last note", value: saved.lastPathComponent)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("PoC notes")
                    .font(.headline)
                Text("• Uses simple Desktop polling, not ScreenCaptureKit yet")
                Text("• Saves notes next to the screenshot as .note.md")
                Text("• Runs as menu-bar utility (LSUIElement)")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(24)
    }
}
