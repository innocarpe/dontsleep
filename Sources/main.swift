import AppKit

private var retainedDelegate: AppDelegate?

enum DontSleepMain {
    static func run() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        retainedDelegate = delegate
        app.delegate = delegate
        app.setActivationPolicy(.accessory)
        app.run()
    }
}

DontSleepMain.run()
