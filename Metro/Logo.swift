import SwiftUI

// A metronome: tapered body with a tilted pendulum arm and weight.
struct Logo: View {
    var size: CGFloat
    var body: some View {
        let w = size * 0.06
        ZStack {
            Path { p in
                p.move(to: CGPoint(x: size * 0.3, y: size)); p.addLine(to: CGPoint(x: size * 0.7, y: size))
                p.addLine(to: CGPoint(x: size * 0.58, y: 0)); p.addLine(to: CGPoint(x: size * 0.42, y: 0))
                p.closeSubpath()
            }.stroke(style: StrokeStyle(lineWidth: w, lineJoin: .round))
            Path { p in p.move(to: CGPoint(x: size * 0.5, y: size * 0.88)); p.addLine(to: CGPoint(x: size * 0.64, y: size * 0.1)) }
                .stroke(style: StrokeStyle(lineWidth: w, lineCap: .round))
            Circle().frame(width: size * 0.14).position(x: size * 0.6, y: size * 0.32)
        }
        .frame(width: size, height: size)
    }
}
