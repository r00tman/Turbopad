<p align=center>Ever wondered what to do with this unnecessarily huge trackpad of yours?<br/> Turns out it's perfect for velocity-sensitive MIDI drum pads, MPE keys, CC's and more!</p>

![drumpad](Art/drumpad.gif)

## Project status
This is a fork of [Dev1an/Trackpad-Drummer](https://github.com/Dev1an/Trackpad-Drummer) project. It works ok, but the last update was in 2018, which is 7 years ago already.

So far, I added support for customizing pads by detecting them automatically from the storyboard. By default it's kick, snare, closed hi-hat and open hi-hat (sent through MIDI; output is customizable in Settings). Also added support for velocity-sensitive playing with built-in sounds. Dev1an detected velocities through touched finger size, which feels surprisingly ok after practice.

Next, I plan adding CC sliders page (pitch bend strip + xy modulation, similar to Arturia KeyStep) so that I could replace my janky and laggy TouchOSC setup with the integrated trackpad.
I would love to see a page with MPE Linnstrument-like keys, they would be super fun to have, however that's definitely not the first priority.

## Installation
I don't have GitHub releases yet, so please clone the repo, do `pod install`, open workspace in Xcode and compile. For some reason, it doesn't work with App Sandbox enabled, so turn it off, idk which entitlement it needs. Also turn off Build Settings->Sandbox user scripts, otherwise it won't build.

## Compatibility

Tested trackpads:
- [x] MacBook Pro 15" Late 2013 (internal trackpad)
- [x] MacBook Pro M1 13" 2020 (internal trackpad)
- [x] Magic trackpad 2

## Features
- Written completely in Swift.
- Outputs to speakers or to a MIDI device. 
- Themed to support macOS Mojave Dark mode
- <a href="https://developer.apple.com/developer-id/"><img alt="Notarized" align=middle src="Art/Notarized.jpg" width=90></a>

### Where to start ... for developers
- User interface: [Main.storyboard](Magic%20Drumpad/Base.lproj/Main.storyboard)
- Application logic: [PadController.swift](Magic%20Drumpad/PadController.swift)
- Audio player: [Player.swift](Magic%20Drumpad/Player.swift)
