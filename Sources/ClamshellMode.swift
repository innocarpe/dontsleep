import AppKit

final class ClamshellMode {
    static let heatKey = "clamshell.releaseOnHeat"

    var releaseOnHeat: Bool {
        get {
            if UserDefaults.standard.object(forKey: Self.heatKey) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: Self.heatKey)
        }
        set { UserDefaults.standard.set(newValue, forKey: Self.heatKey) }
    }

    var onReleased: (() -> Void)?

    private let lid = LidMonitor()
    private let thermal = ThermalMonitor()
    private var running = false
    private var savedDisplay: Float?
    private var savedKeyboard: Float?
    private var reblank: DispatchWorkItem?
    private var observers: [NSObjectProtocol] = []

    func start() {
        stop(restore: false)
        running = true
        lid.onChange = { [weak self] closed in
            self?.handleLid(closed)
        }
        thermal.onDanger = { [weak self] in
            self?.heatTrip()
        }
        lid.start()
        thermal.start()

        let nc = NSWorkspace.shared.notificationCenter
        observers.append(nc.addObserver(
            forName: NSWorkspace.screensDidWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.displayChanged()
        })
        observers.append(NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.displayChanged()
        })
    }

    func stop(restore: Bool) {
        running = false
        reblank?.cancel()
        reblank = nil
        lid.onChange = nil
        thermal.onDanger = nil
        lid.stop()
        thermal.stop()
        for o in observers {
            NotificationCenter.default.removeObserver(o)
            NSWorkspace.shared.notificationCenter.removeObserver(o)
        }
        observers.removeAll()
        if restore {
            restoreOutputs()
        }
    }

    private func handleLid(_ closed: Bool) {
        guard running else { return }
        if closed {
            blank()
        } else {
            restoreOutputs()
        }
    }

    private func displayChanged() {
        guard running, Lid.isClosed() == true else { return }
        blank()
    }

    private func blank() {
        guard running, Lid.isClosed() == true else { return }
        if BuiltinPanel.id() == nil {
            return
        }
        if savedDisplay == nil {
            savedDisplay = BuiltinPanel.brightness()
        }
        if savedKeyboard == nil {
            savedKeyboard = KeyboardLight.brightness()
        }
        KeyboardLight.setBrightness(0)
        BuiltinPanel.sleepNow()
        scheduleReblank()
    }

    private func scheduleReblank() {
        reblank?.cancel()
        let work = DispatchWorkItem { [weak self] in
            guard let self, self.running, Lid.isClosed() == true else { return }
            if BuiltinPanel.id() != nil {
                KeyboardLight.setBrightness(0)
                BuiltinPanel.sleepNow()
                self.scheduleReblank()
            }
        }
        reblank = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: work)
    }

    private func restoreOutputs() {
        reblank?.cancel()
        reblank = nil
        if let display = savedDisplay {
            BuiltinPanel.setBrightness(display)
        }
        if let keyboard = savedKeyboard {
            KeyboardLight.setBrightness(keyboard)
        }
        savedDisplay = nil
        savedKeyboard = nil
    }

    private func heatTrip() {
        guard running, releaseOnHeat else { return }
        if Lid.isClosed() != true {
            restoreOutputs()
        } else {
            reblank?.cancel()
            reblank = nil
            savedDisplay = nil
            savedKeyboard = nil
        }
        running = false
        lid.stop()
        thermal.stop()
        try? Power.setSleepDisabled(false)
        onReleased?()
    }
}
