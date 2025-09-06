<p align=center>Ever wondered what to do with this unnecessarily huge trackpad of yours?<br/> Turns out it's perfect for velocity-sensitive MIDI drum pads, MPE keys, CC's and more!</p>

![drumpad](Art/drumpad.gif)

## Project status
This is a fork of [Dev1an/Trackpad-Drummer](https://github.com/Dev1an/Trackpad-Drummer) project. It works ok, but the last update was in 2018, which is 7 years ago already.

So far, I added
- [x] Procedural drum pads (in PadPageHandler.swift). By default, it's kick, snalre, closed hi-hat and open hi-hat
- [x] CC page (Pitch Bend+Mod XY CC's, similar to Arturia KeyStep)
- [x] Persistent settings (CC mode vs Drum mode, MIDI vs Audio output)
- [x] Window resizing support
- [x] Velocity sensitivity not only for MIDI but for built-in sounds too. Dev1an detected velocities through touched finger size, which feels surprisingly ok after practice.

Ok, so I successfully replaced my janky and laggy TouchOSC setup with the integrated trackpad. One less device with battery to care about, no additional stands, almost instant response, super big=super precise controls. I'm happy.

Next, I want some runtime toggles: on/off switch/global shortcut to avoid Midas touch, absolute/relative modes for slider&mod xy, auto reset for mod xy, toggle between CC and Drum modes. Those already exist, but they are just in the code, no UI control yet.

I would love to see a page with MPE Linnstrument-like keys, they would be super fun to have. Maybe also refactor code so that it's user-configurable, not just through code?

## Installation
I don't have GitHub releases yet, so please clone the repo, do `pod install`, open workspace in Xcode and compile. For some reason, it doesn't work with App Sandbox enabled, so turn it off, idk which entitlement it needs. Also turn off Build Settings->Sandbox user scripts, otherwise it won't build.

## Compatibility

Tested trackpads:
- [x] MacBook Pro 15" Late 2013 (internal trackpad)
- [x] MacBook Pro M1 13" 2020 (internal trackpad)
- [x] Magic trackpad 2

## Features (pre-fork)
- Written completely in Swift.
- Outputs to speakers or to a MIDI device. 
- Themed to support macOS Mojave Dark mode

### Where to start ... for developers
- User interface: [Main.storyboard](Magic%20Drumpad/Base.lproj/Main.storyboard)
- Application logic: [PadController.swift](Magic%20Drumpad/PadController.swift)
- Audio player: [Player.swift](Magic%20Drumpad/Player.swift)
