import Foundation

struct ScreenshotItem: Identifiable, Equatable {
    let id = UUID()
    let url: URL
    let createdAt: Date
}

final class ScreenshotWatcher {
    var onScreenshotDetected: ((ScreenshotItem) -> Void)?

    private var timer: Timer?
    private var knownFiles = Set<String>()
    private let fileManager = FileManager.default
    private lazy var desktopURL = fileManager.homeDirectoryForCurrentUser.appendingPathComponent("Desktop", isDirectory: true)

    func start() {
        preloadKnownFiles()
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.scanNow()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func scanNow() {
        guard let newest = newestScreenshot() else { return }
        let path = newest.url.path
        guard knownFiles.contains(path) == false else { return }
        knownFiles.insert(path)
        onScreenshotDetected?(newest)
    }

    private func preloadKnownFiles() {
        knownFiles = Set(listCandidateFiles().map(\.path))
    }

    private func newestScreenshot() -> ScreenshotItem? {
        listCandidateFiles()
            .compactMap { url -> ScreenshotItem? in
                guard let values = try? url.resourceValues(forKeys: [.creationDateKey]) else { return nil }
                return ScreenshotItem(url: url, createdAt: values.creationDate ?? .distantPast)
            }
            .sorted { $0.createdAt > $1.createdAt }
            .first
    }

    private func listCandidateFiles() -> [URL] {
        guard let urls = try? fileManager.contentsOfDirectory(
            at: desktopURL,
            includingPropertiesForKeys: [.creationDateKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        return urls.filter { url in
            let name = url.lastPathComponent.lowercased()
            let isImage = ["png", "jpg", "jpeg", "heic"].contains(url.pathExtension.lowercased())
            let looksLikeScreenshot = name.hasPrefix("screenshot") || name.hasPrefix("screen shot")
            return isImage && looksLikeScreenshot
        }
    }
}
