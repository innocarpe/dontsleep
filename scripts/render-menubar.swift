import AppKit
import CoreGraphics

// Vector menu-bar glyphs as single-page PDFs (template-friendly).
// Same laptop silhouette. On = solid fill. Off = outline.
// A screen cutout on the filled state reads as another outline at 18pt.

let outDir = CommandLine.arguments.dropFirst().first.map(URL.init(fileURLWithPath:))
    ?? URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        .appendingPathComponent("Assets")

try FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)

enum Kind: String {
    case on, off, error
}

func writePDF(kind: Kind) {
    let url = outDir.appendingPathComponent("Menubar\(kind.rawValue.capitalized).pdf") as CFURL
    var box = CGRect(x: 0, y: 0, width: 18, height: 18)
    guard let ctx = CGContext(url, mediaBox: &box, nil) else {
        fputs("failed to create \(url)\n", stderr)
        exit(1)
    }
    ctx.beginPDFPage(nil)
    ctx.setFillColor(gray: 0, alpha: 1)
    ctx.setStrokeColor(gray: 0, alpha: 1)
    ctx.setLineWidth(lineWidth)
    ctx.setLineCap(.round)
    ctx.setLineJoin(.round)

    switch kind {
    case .on:
        drawLaptop(ctx, filled: true)
    case .off, .error:
        drawLaptop(ctx, filled: false)
    }

    ctx.endPDFPage()
    ctx.closePDF()
}

private let lineWidth: CGFloat = 1.15

func drawLaptop(_ ctx: CGContext, filled: Bool) {
    // Stroke is centered on the path, so a fill of the same path sits
    // half a stroke inside the outline. Expand the filled silhouette
    // by that half-width so on/off share one outer size.
    let outset: CGFloat = filled ? lineWidth / 2 : 0
    let lid = CGRect(x: 2.7, y: 5.8, width: 12.6, height: 8.0)
        .insetBy(dx: -outset, dy: -outset)
    let corner = 1.55 + outset
    let lidPath = CGPath(roundedRect: lid, cornerWidth: corner, cornerHeight: corner, transform: nil)
    let o = outset
    let base = CGMutablePath()
    base.move(to: CGPoint(x: 1.7 - o, y: 5.45 + o))
    base.addLine(to: CGPoint(x: 16.3 + o, y: 5.45 + o))
    base.addQuadCurve(
        to: CGPoint(x: 16.95 + o, y: 3.35 - o),
        control: CGPoint(x: 17.05 + o, y: 4.55)
    )
    base.addLine(to: CGPoint(x: 1.05 - o, y: 3.35 - o))
    base.addQuadCurve(
        to: CGPoint(x: 1.7 - o, y: 5.45 + o),
        control: CGPoint(x: 0.95 - o, y: 4.55)
    )
    base.closeSubpath()

    if filled {
        ctx.addPath(lidPath)
        ctx.addPath(base)
        ctx.fillPath()
    } else {
        ctx.addPath(lidPath)
        ctx.strokePath()
        ctx.addPath(base)
        ctx.strokePath()
    }
}

writePDF(kind: .on)
writePDF(kind: .off)
writePDF(kind: .error)
print("Wrote menu-bar PDFs to \(outDir.path)")
