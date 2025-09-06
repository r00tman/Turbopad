<p align=center>Ever wondered what to do with this unnecessarily huge trackpad of yours?<br/> Turns out it's perfect for MIDI drum pads, MPE keys, CC's and more!</p>

![drumpad](Art/drumpad.gif)

## Installation
This is a fork of Dev1an's project. I don't have releases yet, so please clone the repo, do `pod install`, open workspace and compile. For some reason, it doesn't work with App Sandbox enabled, so turn it off. Also turn off Build Settings->Sandbox user scripts, otherwise it won't build.

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
