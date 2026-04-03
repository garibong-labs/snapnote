import AppKit
import SwiftUI

struct NotePanelView: View {
    @EnvironmentObject private var appState: AppState
    let item: ScreenshotItem

    private var image: NSImage? {
        NSImage(contentsOf: item.url)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("New screenshot")
                .font(.title2.weight(.semibold))

            Text(item.url.lastPathComponent)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .textSelection(.enabled)

            if let image {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.secondary.opacity(0.15))
                    .frame(height: 180)
                    .overlay {
                        Text("Preview unavailable")
                            .foregroundStyle(.secondary)
                    }
            }

            Text("What was this screenshot for?")
                .font(.headline)

            TextEditor(text: $appState.draftText)
                .font(.body)
                .frame(minHeight: 120)
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                }

            HStack {
                Button("Reveal Screenshot") {
                    NSWorkspace.shared.activateFileViewerSelecting([item.url])
                }

                Spacer()

                Button("Save Note") {
                    appState.saveNote(for: item)
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(width: 520, height: 520)
    }
}
