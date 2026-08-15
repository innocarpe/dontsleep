import AppKit

enum StatusIcon {
    static func image(on: Bool?) -> NSImage {
        let resource: String
        switch on {
        case true: resource = "MenubarOn"
        case false: resource = "MenubarOff"
        case nil: resource = "MenubarError"
        }
        if let url = Bundle.main.url(forResource: resource, withExtension: "pdf"),
           let image = NSImage(contentsOf: url) {
            image.isTemplate = true
            image.size = NSSize(width: 18, height: 18)
            return image
        }
        let fallback = on == true ? "moon.slash" : (on == false ? "moon.zzz" : "exclamationmark.triangle")
        return NSImage(systemSymbolName: fallback, accessibilityDescription: AppIdentity.name)
            ?? NSImage()
    }
}
