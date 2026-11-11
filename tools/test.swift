// Usage: ./test.sh. Plain asserts; exits nonzero on failure.
var t = Tick()
var fires: [Int] = []
for i in 0..<48000 * 3 where t.step(rate: 48000, bpm: 120, running: true) { fires.append(i) }
assert(fires == [0, 24000, 48000, 72000, 96000, 120000], "120 bpm: first click now, then every 0.5 s, got \(fires)")

assert(!t.step(rate: 48000, bpm: 120, running: false), "no click while stopped")
assert(t.step(rate: 48000, bpm: 120, running: true), "restart clicks immediately")

var f = Tick(), n = 0
for _ in 0..<48000 where f.step(rate: 48000, bpm: 60, running: true) { n += 1 }
assert(n == 1, "60 bpm: one click per second, got \(n)")

assert(clampBPM(5) == 20 && clampBPM(999) == 300 && clampBPM(120) == 120)
print("ok")
