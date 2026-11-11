// Beat clock, stepped once per audio sample. Fires on the first sample after starting, then every 60/bpm seconds.
struct Tick {
    private var count = Double.infinity
    mutating func step(rate: Double, bpm: Double, running: Bool) -> Bool {
        guard running else { count = .infinity; return false }
        count += 1
        if count >= rate * 60 / bpm { count = 0; return true }
        return false
    }
}

func clampBPM(_ b: Int) -> Int { min(300, max(20, b)) }
