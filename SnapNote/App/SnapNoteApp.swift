import SwiftUI

@main
struct SnapNoteApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    // AppDelegate owns AppState so it can wire the note-panel callback
    // at applicationDidFinishLaunching — before any window appears.
    private var appState: AppState { appDelegate.appState }

    var body: some Scene {
        WindowGroup("SnapNote", id: "main") {
            MainView()
                .environmentObject(appState)
                .frame(minWidth: 420, minHeight: 320)
        }
        .windowResizability(.contentSize)
    }
}
