import SwiftUI

@main
struct SnapNoteApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup("SnapNote", id: "main") {
            MainView()
                .environmentObject(appState)
                .frame(minWidth: 420, minHeight: 320)
                .onAppear {
                    appDelegate.configure(with: appState)
                }
        }
        .windowResizability(.contentSize)
    }
}
