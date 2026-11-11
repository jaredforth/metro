// Usage: icon <out.png>. Renders the app icon (Logo on a dark rounded square) at 1024x1024.
import SwiftUI
import AppKit

struct Icon: View { var body: some View { ZStack {
    RoundedRectangle(cornerRadius: 185).fill(Color(white: 0.11)).frame(width: 824, height: 824)
    Logo(size: 600).foregroundColor(.orange)
}.frame(width: 1024, height: 1024) } }

MainActor.assumeIsolated {
    let r = ImageRenderer(content: Icon())
    r.scale = 1
    let png = NSBitmapImageRep(cgImage: r.cgImage!).representation(using: .png, properties: [:])!
    try! png.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
}
