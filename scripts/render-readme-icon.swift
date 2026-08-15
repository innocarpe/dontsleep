import AppKit

// Mask the square 1024 master into a macOS-like rounded rect with alpha
// for GitHub README. The .icns master stays full-bleed.

let args = CommandLine.arguments
guard args.count >= 3 else {
    fputs("usage: render-readme-icon <in.png> <out.png>\n", stderr)
    exit(2)
}

let srcURL = URL(fileURLWithPath: args[1])
let dstURL = URL(fileURLWithPath: args[2])
guard let src = NSImage(contentsOf: srcURL),
      let cg = src.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
    fputs("could not read \(srcURL.path)\n", stderr)
    exit(1)
}

let dim = 1024
let scale = CGFloat(dim)
// Continuous-corner approximation used by Apple’s 1024 icon grid.
let radius = scale * 0.2237

let colorSpace = CGColorSpaceCreateDeviceRGB()
guard let ctx = CGContext(
    data: nil,
    width: dim,
    height: dim,
    bitsPerComponent: 8,
    bytesPerRow: 0,
    space: colorSpace,
    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
) else {
    exit(1)
}

ctx.setAllowsAntialiasing(true)
ctx.interpolationQuality = .high
let rect = CGRect(x: 0, y: 0, width: scale, height: scale)
let path = CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)
ctx.addPath(path)
ctx.clip()
ctx.draw(cg, in: rect)

guard let out = ctx.makeImage() else { exit(1) }
let rep = NSBitmapImageRep(cgImage: out)
rep.size = NSSize(width: dim, height: dim)
guard let png = rep.representation(using: .png, properties: [:]) else { exit(1) }
try png.write(to: dstURL)
print("Wrote \(dstURL.path)")
