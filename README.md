<p align=center>Ever wondered what to do with this <em>unnecessarily huge trackpad</em> of yours?<br/> Turns out it's perfect for velocity-sensitive MIDI drum pads, CC's, <b>**MPE** guitars</b> and more!<br/>Did I already tell you that <b>it is all free and always with you as it is built into your laptop?</b> :)</p>

https://github.com/user-attachments/assets/ae6cb475-0d78-4b82-80ac-f43aefdf63b4

<img width="2219" height="595" alt="Image" src="https://github.com/user-attachments/assets/bbb5a886-3e56-4579-812c-a8da6016f191" />

## DISCLAIMER

The day I started this repo, I also learned that there is already [Audioswift](https://audioswiftapp.com/), thanks Google. I have neither bought it, nor ever tried it, nor even downloaded it. But it seems to do quite similar things, so please **CONSIDER BUYING AUDIOSWIFT INSTEAD OF USING THIS REPO**, as I am 100% sure that it is **MUCH MORE POLISHED** than the current state of this repo and that AudioSwift's developer will be **MUCH HAPPIER** too if you do. I'll continue developing this repo anyway, as I want to play around with this idea myself, with the max level of control and customization possible, i.e., with direct access to my source code.

## Project status
This is a fork of [Dev1an/Trackpad-Drummer](https://github.com/Dev1an/Trackpad-Drummer) project. It works ok, but the last update was in 2018, which is 7 years ago already. About 2 weeks in after forking, I left the fork network so that the repo could show up in search results and etc.

I got super inspired by [Anatole Muster](https://www.youtube.com/shorts/1kVAUZjotnE) using his *laptop keyboard* as a makeshift accordion. I wondered if I could do the similar stuff with a *laptop trackpad*. I use Maschine and Launchpads a lot, and it seemed doable to replicate (and improve upon) the experience with just a damn built-in trackpad. So, I went ahead with it, found [Dev1an's repo](https://github.com/Dev1an/Trackpad-Drummer) and hacked a lot of stuff in :)

So far, I added
- [x] Custom drum pad layouts using the layout grid in PadPageHandler.swift. By default, it's kick, snare, closed/open hi-hats, 3 toms, 2 crashes, ride (MIDI notes are still defined in SettingsController.swift). This is highly inspired by [my default Maschine layout](https://github.com/r00tman/maschine-mikro-mk3-driver), which is heavily inspired by [Dragon Finger Drums channel](https://www.youtube.com/@DragonFingerDrums).
- [x] CC control page (MIDI Pitch Bend+Mod XY CC's, similar to Arturia KeyStep)
- [x] **MPE** Guitar mode with sliding support (5 strings, 7+1 frets by default):
  - [x] discrete slide mode (note on new note, note off old note)
  - [x] global slide mode (pitch bend the entire channel if finger moved enough)
  - [x] per-note slide pitch bend support (MPE) -- **default**
- [x] Persistent settings through UserDefaults (Active mode, MIDI vs Audio output)
- [x] Runtime **global** hotkey toggles:
  - [x] toggle between CC, Drum, and Guitar modes **(Cmd+Shift+F7),**
  - [x] mouse lock/unlock and bring app to front **(Cmd+Shift+F8),**
  - [x] on/off switch/global shortcut to avoid Midas touch **(Cmd+Shift+F9),**
  - [x] absolute/relative modes for slider&mod xy **(Cmd+Shift+F10 for PB, Cmd+Shift+F11 for Mod),**
  - [x] auto reset for mod xy **(Cmd+Shift+F12)**.
- [x] Velocity sensitivity not only for MIDI but for built-in sounds too. Dev1an detected velocities through touched finger size, which feels surprisingly ok after practice.
- [x] Window resizing support
- [x] Fix building and archiving (creating release bundle) for 2025


Ok, so I successfully replaced my janky and laggy [TouchOSC](https://hexler.net/touchosc) setup with the integrated trackpad. One less device with battery to care about, no additional stands, **almost instant response**, super big=super precise controls. I'm happy.

In addition, it looks like I even replaced my [Launchpad95](https://github.com/hdavid/Launchpad95) Launchpad X setup. Moreover, with MPE sliding support, it is getting into [Ableton Push 3](https://www.soundonsound.com/reviews/ableton-push-3) territory without needing to pay 949 EUR or to carry heavy and bulky hardware. I think this is by far **the cheapest way into live MPE playing**, no other hardware is anywhere close the 0 EUR pricetag of this app. I find this absolutely mindblowing, I did this with just an (oversized) built-in trackpad.

It does take about a week of practice to get accuracy and speed comparable to using physical pads, but after that, it works really well. Compared to cheap drum pads, the sensitivity of Apple trackpads is **extremely good**: even the lightest and fastest touches register well, which makes it really good for *fingerdrumming*. This is also good for MPE guitar mode, where my non-MPE Launchpad X sometimes fails to register lighter touches.

**What's next?** I finished adding guitar mode and MPE support to it.  Now I would love to refactor code so that it's more user-configurable, not just through code, e.g.,
 - guitar mode settings:
   - [x] base note and octave,
   - [ ] slide mode,
   - [ ] no of strings/frets,
   - [ ] custom string tuning,
 - drum pad layout and assignments?

Other than that, I think I'm close to packaging the release binaries in a dmg, but first I need to fix some crashes and bugs where notes/fingers get stuck sometimes.

It would be super cool to support microtonal tunings in guitar mode by shifting fret positions like in [Tolgahan's guitars](https://www.youtube.com/@microtonalguitar) (e.g., through scala files & MPE pitch bend messages). Or at least have different EDO's.

I'm also considering adding a hex-keyed harmonic table mode, as on [Lumatone](https://www.lumatone.io/) or [Exquis](https://dualo.com/en/exquis/). But it's probably be just a toy rather than a useful instrument due to the limited number of keys that could fit the trackpad. I think already implemented MPE guitar mode is likely more playable and usable.

## Installation
I don't have GitHub releases yet, so please clone the repo, do `pod install`, open workspace in Xcode and compile. For some reason, it doesn't work with App Sandbox enabled, so I turned it off, idk which entitlement it needs. Also turn off Build Settings->Sandbox user scripts (if it is on), otherwise it won't build.

For archiving (building release bundle) to work, install libarc files which were removed in Xcode 14.3 (needed for M5MultitouchSupport library, last updated 10 years ago in 2015):

```bash
git clone https://github.com/kamyarelyasi/Libarclite-Files.git
sudo cp Libarclite-Files/*.a /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/arc/
```

## Compatibility

Tested trackpads:
- [x] MacBook Pro M1 16" 2021 (internal trackpad)
- [x] MacBook Pro 15" Late 2013 (internal trackpad, tested by Dev1an in his repo)
- [x] MacBook Pro M1 13" 2020 (internal trackpad, tested by alcibiadesc in Dev1an's repo)
- [x] Magic trackpad 2 (tested by Dev1an in his repo)

## Features
- Written completely in Swift
- Outputs to MIDI MPE, MIDI or to speakers
- Velocity-sensitive drumpads
- CC control mode with pitch bend and XY modulation
- **MPE** guitar mode with sliding
- Global shortcuts to configure settings
- Themed to support macOS Mojave Dark mode

### Where to start ... for developers
- User interface: [Main.storyboard](Turbopad/Base.lproj/Main.storyboard)
- Base app logic: [TrackpadController.swift](Turbopad/TrackpadController.swift)
- Different modes handlers: [PadPageHandler.swift](Turbopad/PadPageHandler.swift), [CCPageHandler.swift](Turbopad/CCPageHandler.swift), [GuitarPageHandler.swift](Turbopad/GuitarPageHandler.swift)
- Settings controller (drum pad MIDI tuning and audio samples): [SettingsController.swift](SettingsController.swift)
- Audio player: [Player.swift](Turbopad/Player.swift)
