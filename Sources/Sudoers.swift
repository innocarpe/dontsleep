import Foundation

enum Sudoers {
    /// Writes /etc/sudoers.d/dontsleep for the current user via a one-time
    /// administrator password dialog. Does not change the current sleep flag.
    static func install() throws {
        let user = NSUserName()
        let rule = "\(user) ALL=(root) NOPASSWD: /usr/bin/pmset -a disablesleep 1, /usr/bin/pmset -a disablesleep 0"
        let tmp = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("dontsleep-sudoers-\(UUID().uuidString)")
        try (rule + "\n").write(to: tmp, atomically: true, encoding: .utf8)

        let script = """
        do shell script "install -m 0440 -o root -g wheel " & quoted form of "\(tmp.path)" & " /etc/sudoers.d/dontsleep && /usr/sbin/visudo -cf /etc/sudoers.d/dontsleep" with administrator privileges
        """
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        proc.arguments = ["-e", script]
        let err = Pipe()
        proc.standardError = err
        proc.standardOutput = FileHandle.nullDevice
        try proc.run()
        proc.waitUntilExit()
        try? FileManager.default.removeItem(at: tmp)
        if proc.terminationStatus != 0 {
            throw PowerError.sudoersMissing
        }
        if !Power.hasPasswordlessAccess() {
            throw PowerError.sudoersMissing
        }
    }
}
