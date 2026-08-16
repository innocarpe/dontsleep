import CoreGraphics
import Darwin
import Foundation

enum BuiltinPanel {
    private static let framework =
        "/System/Library/PrivateFrameworks/DisplayServices.framework/DisplayServices"

    private static let handle: UnsafeMutableRawPointer? = {
        dlopen(framework, RTLD_LAZY)
    }()

    private static let getFn: (@convention(c) (UInt32, UnsafeMutablePointer<Float>) -> Int32)? = {
        guard let h = handle, let p = dlsym(h, "DisplayServicesGetBrightness") else {
            return nil
        }
        return unsafeBitCast(p, to: (@convention(c) (UInt32, UnsafeMutablePointer<Float>) -> Int32).self)
    }()

    private static let setFn: (@convention(c) (UInt32, Float) -> Int32)? = {
        guard let h = handle, let p = dlsym(h, "DisplayServicesSetBrightness") else {
            return nil
        }
        return unsafeBitCast(p, to: (@convention(c) (UInt32, Float) -> Int32).self)
    }()

    static func id() -> CGDirectDisplayID? {
        var count: UInt32 = 0
        CGGetOnlineDisplayList(0, nil, &count)
        var ids = [CGDirectDisplayID](repeating: 0, count: Int(count))
        CGGetOnlineDisplayList(count, &ids, &count)
        return ids.prefix(Int(count)).first { CGDisplayIsBuiltin($0) != 0 }
    }

    static func brightness() -> Float? {
        guard let id = id(), let getFn else { return nil }
        var value: Float = -1
        let err = getFn(id, &value)
        return err == 0 ? value : nil
    }

    static func setBrightness(_ value: Float) {
        guard let id = id(), let setFn else { return }
        _ = setFn(id, max(0, min(1, value)))
    }

    static func sleepNow() {
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/usr/bin/pmset")
        proc.arguments = ["displaysleepnow"]
        proc.standardOutput = FileHandle.nullDevice
        proc.standardError = FileHandle.nullDevice
        try? proc.run()
        proc.waitUntilExit()
    }
}
