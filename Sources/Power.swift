import Foundation

enum Power {
    private static let pmset = "/usr/bin/pmset"
    private static let sudo = "/usr/bin/sudo"

    static func sleepDisabled() -> Result<Bool, Error> {
        do {
            let out = try run(pmset, ["-g"])
            for line in out.split(whereSeparator: \.isNewline) {
                let parts = line.split(whereSeparator: \.isWhitespace)
                guard parts.first.map(String.init) == "SleepDisabled",
                      let value = parts.last else { continue }
                return .success(value == "1")
            }
            return .success(false)
        } catch {
            return .failure(error)
        }
    }

    static func setSleepDisabled(_ disabled: Bool) throws {
        let flag = disabled ? "1" : "0"
        // Must match /etc/sudoers.d/dontsleep argv exactly.
        _ = try run(sudo, ["-n", pmset, "-a", "disablesleep", flag])
        if case .success(let now) = sleepDisabled(), now != disabled {
            throw PowerError.verifyFailed
        }
    }

    private static func run(_ exe: String, _ args: [String]) throws -> String {
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: exe)
        proc.arguments = args
        let stdout = Pipe()
        let stderr = Pipe()
        proc.standardOutput = stdout
        proc.standardError = stderr
        do {
            try proc.run()
        } catch {
            throw PowerError.spawnFailed(exe)
        }
        proc.waitUntilExit()
        let err = String(data: stderr.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let out = String(data: stdout.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        if proc.terminationStatus != 0 {
            if exe == sudo {
                throw PowerError.sudoersMissing
            }
            throw PowerError.commandFailed(exe, proc.terminationStatus, err)
        }
        return out
    }
}

enum PowerError: LocalizedError {
    case spawnFailed(String)
    case commandFailed(String, Int32, String)
    case sudoersMissing
    case verifyFailed

    var errorDescription: String? {
        switch self {
        case .spawnFailed(let exe):
            return String(format: L10n.string("error.spawn"), exe)
        case .commandFailed(let exe, let status, let err):
            if err.isEmpty {
                return String(format: L10n.string("error.command"), exe, status)
            }
            return String(format: L10n.string("error.commandDetail"), exe, status, err)
        case .sudoersMissing:
            return L10n.string("error.sudoers")
        case .verifyFailed:
            return L10n.string("error.verify")
        }
    }
}
