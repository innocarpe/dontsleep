import Darwin
import Foundation
import ObjectiveC

enum KeyboardLight {
    private static let framework =
        "/System/Library/PrivateFrameworks/CoreBrightness.framework/CoreBrightness"

    private static let client: NSObject? = {
        _ = dlopen(framework, RTLD_LAZY)
        guard let cls = NSClassFromString("KeyboardBrightnessClient") as? NSObject.Type else {
            return nil
        }
        return cls.init()
    }()

    private static func keyboardID() -> UInt64? {
        guard let client else { return nil }
        let sel = NSSelectorFromString("copyKeyboardBacklightIDs")
        guard client.responds(to: sel),
              let raw = client.perform(sel)?.takeUnretainedValue(),
              let ids = raw as? [NSNumber],
              let first = ids.first else {
            return nil
        }
        return first.uint64Value
    }

    static func brightness() -> Float? {
        guard let client, let id = keyboardID() else { return nil }
        let sel = NSSelectorFromString("brightnessForKeyboard:")
        guard client.responds(to: sel) else { return nil }
        typealias Imp = @convention(c) (AnyObject, Selector, UInt64) -> Float
        let fn = unsafeBitCast(client.method(for: sel), to: Imp.self)
        return fn(client, sel, id)
    }

    static func setBrightness(_ value: Float) {
        guard let client, let id = keyboardID() else { return }
        let sel = NSSelectorFromString("setBrightness:forKeyboard:")
        guard client.responds(to: sel) else { return }
        typealias Imp = @convention(c) (AnyObject, Selector, Float, UInt64) -> ObjCBool
        let fn = unsafeBitCast(client.method(for: sel), to: Imp.self)
        _ = fn(client, sel, max(0, min(1, value)), id)
    }
}
