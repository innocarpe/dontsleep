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
        let clamped = max(0, min(1, value))
        let commitSel = NSSelectorFromString("setBrightness:fadeSpeed:commit:forKeyboard:")
        if client.responds(to: commitSel) {
            typealias Imp = @convention(c) (AnyObject, Selector, Float, Int32, ObjCBool, UInt64) -> ObjCBool
            let fn = unsafeBitCast(client.method(for: commitSel), to: Imp.self)
            _ = fn(client, commitSel, clamped, 0, true, id)
        }
        let sel = NSSelectorFromString("setBrightness:forKeyboard:")
        guard client.responds(to: sel) else { return }
        typealias Imp = @convention(c) (AnyObject, Selector, Float, UInt64) -> ObjCBool
        let fn = unsafeBitCast(client.method(for: sel), to: Imp.self)
        _ = fn(client, sel, clamped, id)
    }

    static func isSuppressed() -> Bool {
        guard let client, let id = keyboardID() else { return false }
        let sel = NSSelectorFromString("isBacklightSuppressedOnKeyboard:")
        guard client.responds(to: sel) else { return false }
        typealias Imp = @convention(c) (AnyObject, Selector, UInt64) -> ObjCBool
        return unsafeBitCast(client.method(for: sel), to: Imp.self)(client, sel, id).boolValue
    }
}
