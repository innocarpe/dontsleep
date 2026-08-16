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
    private var lastOpenDisplay: Float?
    private var lastOpenKeyboard: Float?
    private var reblank: DispatchWorkItem?
    private var restoreWork: DispatchWorkItem?
    private var observers: [NSObjectProtocol] = []

    func start() {
        stop(restore: false)
        running = true
        lid.onChange = { [weak self] closed in
            self?.handleLid(closed)
        }
        lid.onOpenIdle = { [weak self] in
            self?.rememberOpenLevels()
        }
        thermal.onDanger = { [weak self] in
            self?.heatTrip()
        }
        lid.start()
        rememberOpenLevels()
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
        restoreWork?.cancel()
        restoreWork = nil
        lid.onChange = nil
        lid.onOpenIdle = nil
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

    private func rememberOpenLevels() {
        guard Lid.isClosed() != true else { return }
        if let display = BuiltinPanel.brightness(), display > 0.02 {
            lastOpenDisplay = display
        }
        if let keyboard = KeyboardLight.brightness(),
           keyboard > 0.02,
           !KeyboardLight.isSuppressed() {
            lastOpenKeyboard = keyboard
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
            savedDisplay = lastOpenDisplay ?? BuiltinPanel.brightness()
        }
        if savedKeyboard == nil {
            let now = KeyboardLight.brightness()
            if let lastOpenKeyboard {
                savedKeyboard = lastOpenKeyboard
            } else if let now, now > 0.02, !KeyboardLight.isSuppressed() {
                savedKeyboard = now
            }
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
        let display = savedDisplay ?? lastOpenDisplay
        let keyboard = savedKeyboard ?? lastOpenKeyboard
        savedDisplay = display
        savedKeyboard = keyboard
        applyRestore(display: display, keyboard: keyboard, attempt: 0)
    }

    private func applyRestore(display: Float?, keyboard: Float?, attempt: Int) {
        guard running, Lid.isClosed() != true else { return }
        if let display {
            BuiltinPanel.setBrightness(display)
        }
        if let keyboard {
            KeyboardLight.setBrightness(keyboard)
        }
        let keyboardOK: Bool = {
            guard let keyboard else { return true }
            if KeyboardLight.isSuppressed() { return false }
            guard let now = KeyboardLight.brightness() else { return false }
            return abs(now - keyboard) < 0.05
        }()
        if keyboardOK || attempt >= 10 {
            if keyboardOK {
                savedDisplay = nil
                savedKeyboard = nil
            }
            return
        }
        restoreWork?.cancel()
        let work = DispatchWorkItem { [weak self] in
            self?.applyRestore(display: display, keyboard: keyboard, attempt: attempt + 1)
        }
        restoreWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: work)
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
