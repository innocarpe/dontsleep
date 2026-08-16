import Foundation
import IOKit
import IOKit.pwr_mgt
import notify

enum Thermal {
    static func isDangerous() -> Bool {
        var level: UInt32 = 0
        let err = IOPMGetThermalWarningLevel(&level)
        if err != KERN_SUCCESS {
            return false
        }
        return level != 0
    }
}

final class ThermalMonitor {
    var onDanger: (() -> Void)?

    private var token: Int32 = 0
    private var registered = false
    private var timer: Timer?

    func start() {
        stop()
        let name = kIOPMThermalWarningNotificationKey as String
        let status = notify_register_dispatch(name, &token, .main) { [weak self] _ in
            self?.check()
        }
        registered = status == NOTIFY_STATUS_OK
        timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
            self?.check()
        }
        timer?.tolerance = 4
        check()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        if registered {
            notify_cancel(token)
            registered = false
        }
    }

    private func check() {
        if Thermal.isDangerous() {
            onDanger?()
        }
    }
}
