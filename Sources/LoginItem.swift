import Foundation

enum LoginItem {
    static var plistURL: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/LaunchAgents/\(AppIdentity.bundleID).plist")
    }

    static var isEnabled: Bool {
        FileManager.default.fileExists(atPath: plistURL.path)
    }

    static func setEnabled(_ enabled: Bool) {
        // Only persist the next-login agent. Do not bootout — that would
        // kill this process if launchd started it.
        if enabled {
            writePlist()
        } else {
            try? FileManager.default.removeItem(at: plistURL)
        }
    }

    private static func writePlist() {
        let exe = Bundle.main.bundleURL.appendingPathComponent("Contents/MacOS/DontSleep").path
        let plist: [String: Any] = [
            "Label": AppIdentity.bundleID,
            "ProgramArguments": [exe],
            "RunAtLoad": true,
            "KeepAlive": false,
        ]
        let data = try? PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        let dir = plistURL.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        try? data?.write(to: plistURL, options: .atomic)
    }
}
