import Foundation

enum Sudoers {
    static let shortCommand = "sudo write-sudoers.sh"

    static var helperURL: URL? {
        Bundle.main.url(forResource: "write-sudoers", withExtension: "sh")
    }

    /// Command a user can paste into Terminal.app. Same helper the app runs.
    static var shellCommand: String {
        let path = helperURL?.path
            ?? "\(Bundle.main.bundlePath)/Contents/Resources/write-sudoers.sh"
        return "sudo \(quote(path)) \(NSUserName())"
    }

    /// Writes /etc/sudoers.d/dontsleep for the current user via a one-time
    /// administrator password dialog. Does not change the current sleep flag.
    static func install() throws {
        guard let helper = helperURL else {
            throw PowerError.sudoersMissing
        }
        let user = NSUserName()
        let script = """
        do shell script (quoted form of "\(helper.path)") & " " & (quoted form of "\(user)") with administrator privileges
        """
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        proc.arguments = ["-e", script]
        let err = Pipe()
        proc.standardError = err
        proc.standardOutput = FileHandle.nullDevice
        try proc.run()
        proc.waitUntilExit()
        if proc.terminationStatus != 0 {
            throw PowerError.sudoersMissing
        }
        if !Power.hasPasswordlessAccess() {
            throw PowerError.sudoersMissing
        }
    }

    private static func quote(_ path: String) -> String {
        "'" + path.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }
}
