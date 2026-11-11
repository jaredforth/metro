import SwiftUI
import AVFoundation

// Click is sample-accurate: the audio thread counts samples and starts a click every beat.
// Audio thread reads `bpm`/`running` racily; fine for Doubles/Bools on arm64/x86_64.
final class Clicker {
    private let engine = AVAudioEngine()
    let bpm = UnsafeMutablePointer<Double>.allocate(capacity: 1)
    let running = UnsafeMutablePointer<Bool>.allocate(capacity: 1)
    let beats = UnsafeMutablePointer<Int>.allocate(capacity: 1) // total clicks so far, polled by the UI

    init() {
        bpm.initialize(to: 120); running.initialize(to: false); beats.initialize(to: 0)
        let rate = engine.outputNode.outputFormat(forBus: 0).sampleRate
        var count = Double.infinity, env = 0.0, phase = 0.0, wasRunning = false
        let node = AVAudioSourceNode { [bpm, running, beats] _, _, frames, abl in
            for buf in UnsafeMutableAudioBufferListPointer(abl) {
                let out = buf.mData!.assumingMemoryBound(to: Float.self)
                for i in 0..<Int(frames) {
                    if running.pointee {
                        if !wasRunning { count = .infinity; wasRunning = true } // first click right away
                        count += 1
                        if count >= rate * 60 / bpm.pointee { count = 0; env = 1; phase = 0; beats.pointee += 1 }
                    } else { wasRunning = false }
                    phase += 1500 / rate
                    out[i] = Float(0.6 * env * sin(2 * Double.pi * phase))
                    env *= 0.9985 // ~30 ms decay
                }
            }
            return noErr
        }
        engine.attach(node)
        engine.connect(node, to: engine.mainMixerNode, format: AVAudioFormat(standardFormatWithSampleRate: rate, channels: 1))
        try? engine.start()
    }
}

final class Model: ObservableObject {
    @Published var bpm = 120 { didSet { bpm = min(300, max(20, bpm)); clicker.bpm.pointee = Double(bpm) } }
    @Published var running = false
    @Published var flash = false
    private let clicker = Clicker()
    private var seen = 0

    // Up/right = faster, down/left = slower (shift = 10); space/return starts and stops.
    init() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [unowned self] e in
            let step = e.modifierFlags.contains(.shift) ? 10 : 1
            switch e.keyCode {
            case 123, 125: bpm -= step
            case 124, 126: bpm += step
            case 49, 36: toggle()
            default: return e
            }
            return nil
        }
        // Poll the audio thread's beat counter to flash the dot (~60 Hz).
        Timer.scheduledTimer(withTimeInterval: 1.0 / 60, repeats: true) { [unowned self] _ in
            let b = clicker.beats.pointee
            if b != seen { seen = b; flash = true; DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { self.flash = false } }
        }
    }

    func toggle() { running.toggle(); clicker.running.pointee = running }
}

struct MetroView: View {
    @ObservedObject var model: Model

    var body: some View {
        VStack(spacing: 28) {
            Circle().fill(model.flash ? Color.orange : Color.gray.opacity(0.35)).frame(width: 120, height: 120)
            Text("\(model.bpm)").font(.system(size: 96, weight: .light, design: .rounded)).monospacedDigit()
            HStack(spacing: 16) {
                Button("−") { model.bpm -= 1 }
                Button(model.running ? "Stop" : "Start") { model.toggle() }.frame(width: 80)
                Button("+") { model.bpm += 1 }
            }.font(.title2).controlSize(.large)
        }
    }
}

@main
struct MetroApp: App {
    // ObservableObject, not @State: the @State macro needs Xcode's plugin, absent with Command Line Tools only.
    @StateObject private var model = Model()

    var body: some Scene {
        WindowGroup {
            MetroView(model: model).frame(minWidth: 360, minHeight: 440)
        }
    }
}
