import Foundation
import IOKit
import IOKit.pwr_mgt

enum Lid {
    /// nil = no clamshell (desktop). true = closed.
    static func isClosed() -> Bool? {
        let svc = IOServiceGetMatchingService(
            kIOMainPortDefault,
            IOServiceMatching("IOPMrootDomain")
        )
        guard svc != 0 else { return nil }
        defer { IOObjectRelease(svc) }
        guard let raw = IORegistryEntryCreateCFProperty(
            svc,
            "AppleClamshellState" as CFString,
            kCFAllocatorDefault,
            0
        )?.takeRetainedValue() else {
            return nil
        }
        if let b = raw as? Bool { return b }
        if let n = raw as? NSNumber { return n.boolValue }
        return nil
    }
}

final class LidMonitor {
    var onChange: ((Bool) -> Void)?
    var onOpenIdle: (() -> Void)?

    private var last: Bool?
    private var notify: io_object_t = 0
    private var port: IONotificationPortRef?
    private var root: io_service_t = 0
    private var timer: Timer?

    func start() {
        stop()
        root = IOServiceGetMatchingService(
            kIOMainPortDefault,
            IOServiceMatching("IOPMrootDomain")
        )
        if root != 0 {
            let p = IONotificationPortCreate(kIOMainPortDefault)
            port = p
            IONotificationPortSetDispatchQueue(p, .main)
            let selfPtr = Unmanaged.passUnretained(self).toOpaque()
            let err = IOServiceAddInterestNotification(
                p,
                root,
                kIOGeneralInterest,
                { _, _, _, _ in
                    LidMonitor.current?.poke()
                },
                selfPtr,
                &notify
            )
            if err != KERN_SUCCESS {
                notify = 0
            }
        }
        LidMonitor.current = self
        timer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { [weak self] _ in
            self?.poke()
        }
        timer?.tolerance = 0.2
        poke()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        if notify != 0 {
            IOObjectRelease(notify)
            notify = 0
        }
        if let port {
            IONotificationPortDestroy(port)
            self.port = nil
        }
        if root != 0 {
            IOObjectRelease(root)
            root = 0
        }
        if LidMonitor.current === self {
            LidMonitor.current = nil
        }
        last = nil
    }

    func poke() {
        guard let closed = Lid.isClosed() else { return }
        if last != closed {
            last = closed
            onChange?(closed)
            return
        }
        if closed == false {
            onOpenIdle?()
        }
    }

    private static weak var current: LidMonitor?
}
