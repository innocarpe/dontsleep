import AppKit

private var retainedDelegate: AppDelegate?

enum DontSleepMain {
    static func run() {
        if CommandLine.arguments.contains("--probe") {
            print("lid_closed=\(String(describing: Lid.isClosed()))")
            print("display=\(String(describing: BuiltinPanel.id())) brightness=\(String(describing: BuiltinPanel.brightness()))")
            print("keyboard=\(String(describing: KeyboardLight.brightness()))")
            print("thermal_danger=\(Thermal.isDangerous())")
            exit(0)
        }
        let app = NSApplication.shared
        let delegate = AppDelegate()
        retainedDelegate = delegate
        app.delegate = delegate
        app.setActivationPolicy(.accessory)
        app.run()
    }
}

DontSleepMain.run()
