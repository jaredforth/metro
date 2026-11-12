# Metro

Minimal macOS app: a metronome. Big BPM number, a dot that flashes on each beat, Start/Stop and −/+ buttons. Keys: space/return start/stop, arrows change BPM (shift = ±10). Range 20–300, default 120.

## Layout
- `Metro/Metro.swift` (app, audio, `MetroView`) and `Metro/Logo.swift` (icon art, shared with `tools/main.swift`, which renders the icon). No Xcode project, no deps. `build.sh` compiles with `swiftc` into `build/Metro.app` (hand-written Info.plist).
- `Clicker` generates clicks on the audio thread (800 Hz sine, fast decay) by counting samples, so timing doesn't depend on UI timers. The UI polls its beat counter at 60 Hz to flash the dot.

## Tests
`./test.sh` runs plain asserts (`tools/test.swift`) against `Metro/Tick.swift`, the beat clock and BPM clamp split out of the audio callback so they're testable. No framework.

## Decisions
- No accent/time signature, tap tempo, or persistence yet; add when needed.
- Not code-signed; built locally it runs fine.

## Build
`./build.sh && open build/Metro.app`
