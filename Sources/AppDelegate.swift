import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private var statusItem: NSStatusItem!
    private var menu: NSMenu!
    private var timer: Timer?
    private var statusLine: NSMenuItem!
    private var errorLine: NSMenuItem!
    private var onItem: NSMenuItem!
    private var offItem: NSMenuItem!
    private var loginMenuItem: NSMenuItem!
    private var lastOn: Bool?
    private var didRender = false
    private var poppingMenu = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        let others = NSRunningApplication.runningApplications(withBundleIdentifier: AppIdentity.bundleID)
            .filter { $0.processIdentifier != ProcessInfo.processInfo.processIdentifier }
        if !others.isEmpty {
            NSApp.terminate(nil)
            return
        }

        NSApp.setActivationPolicy(.accessory)

        // autosaveName is the stable id Bartender / Control Center persist.
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.autosaveName = NSStatusItem.AutosaveName("DontSleep")
        statusItem.isVisible = true
        statusItem.button?.imageScaling = .scaleProportionallyDown
        statusItem.button?.imagePosition = .imageOnly
        statusItem.button?.setAccessibilityTitle(AppIdentity.name)
        statusItem.button?.target = self
        statusItem.button?.action = #selector(statusItemClicked)
        statusItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])

        menu = NSMenu()
        menu.autoenablesItems = false
        menu.delegate = self
        menu.addItem(header(AppIdentity.name))
        statusLine = header(L10n.string("menu.status.unknown"))
        menu.addItem(statusLine)
        errorLine = header("")
        errorLine.isHidden = true
        menu.addItem(errorLine)
        menu.addItem(.separator())
        onItem = item(L10n.string("menu.turnOn"), action: #selector(turnOn), key: "1")
        menu.addItem(onItem)
        offItem = item(L10n.string("menu.turnOff"), action: #selector(turnOff), key: "0")
        menu.addItem(offItem)
        menu.addItem(.separator())
        loginMenuItem = item(L10n.string("menu.startAtLogin"), action: #selector(toggleLogin), key: "")
        menu.addItem(loginMenuItem)
        menu.addItem(item(L10n.string("menu.refresh"), action: #selector(refreshMenu), key: "r"))
        menu.addItem(.separator())
        menu.addItem(item(L10n.string("menu.quit"), action: #selector(quit), key: "q"))

        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 8, repeats: true) { [weak self] _ in
            self?.refresh()
        }
        timer?.tolerance = 2
    }

    @objc private func statusItemClicked(_ sender: Any?) {
        if poppingMenu { return }
        let event = NSApp.currentEvent
        let right = event?.type == .rightMouseUp || (event?.modifierFlags.contains(.control) ?? false)
        if right {
            popMenu()
            return
        }
        switch Power.sleepDisabled() {
        case .success(let on):
            apply(disabled: !on)
        case .failure:
            popMenu()
        }
    }

    private func popMenu() {
        poppingMenu = true
        statusItem.menu = menu
        statusItem.button?.performClick(nil)
    }

    func menuDidClose(_ menu: NSMenu) {
        statusItem.menu = nil
        poppingMenu = false
    }

    @objc private func turnOn() { apply(disabled: true) }
    @objc private func turnOff() { apply(disabled: false) }
    @objc private func refreshMenu() { didRender = false; refresh() }
    @objc private func toggleLogin(_ sender: NSMenuItem) {
        LoginItem.setEnabled(!LoginItem.isEnabled)
        loginMenuItem.state = LoginItem.isEnabled ? .on : .off
    }
    @objc private func quit() { NSApp.terminate(nil) }

    private func apply(disabled: Bool) {
        do {
            try Power.setSleepDisabled(disabled)
        } catch {
            present(error)
        }
        didRender = false
        refresh()
    }

    private func refresh() {
        render(state: Power.sleepDisabled())
    }

    private func render(state: Result<Bool, Error>) {
        let on: Bool?
        let errText: String?
        switch state {
        case .success(let value):
            on = value
            errText = nil
        case .failure(let error):
            on = nil
            errText = error.localizedDescription
        }

        loginMenuItem.state = LoginItem.isEnabled ? .on : .off
        guard !didRender || lastOn != on else { return }
        didRender = true
        lastOn = on

        statusItem.button?.image = StatusIcon.image(on: on)
        statusItem.button?.toolTip = {
            switch on {
            case true: return L10n.string("tooltip.on")
            case false: return L10n.string("tooltip.off")
            case nil: return L10n.string("tooltip.unknown")
            }
        }()

        switch on {
        case true: statusLine.title = L10n.string("menu.status.on")
        case false: statusLine.title = L10n.string("menu.status.off")
        case nil: statusLine.title = L10n.string("menu.status.unknown")
        }
        errorLine.title = errText ?? ""
        errorLine.isHidden = errText == nil
        onItem.isEnabled = on != true
        offItem.isEnabled = on != false
    }

    private func header(_ title: String) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        item.isEnabled = false
        return item
    }

    private func item(_ title: String, action: Selector, key: String) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: key)
        item.target = self
        return item
    }

    private func present(_ error: Error) {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = AppIdentity.name
        alert.informativeText = error.localizedDescription
        alert.runModal()
    }
}
