//
//  SettingsController.swift
//  Magic Drumpad
//
//  Created by Damiaan on 4/08/18.
//  Copyright © 2018 Damiaan Dufaux. All rights reserved.
//

import Cocoa

let soundDrummers = [
    SoundPlayer(withSound: NSDataAsset(name: .init("drum1"))!.data),
    SoundPlayer(withSound: NSDataAsset(name: .init("drum3"))!.data),
    SoundPlayer(withSound: NSDataAsset(name: .init("drum2"))!.data),
	SoundPlayer(withSound: NSDataAsset(name: .init("drum2"))!.data),
	
	SoundPlayer(withSound: NSDataAsset(name: .init("drum1"))!.data),
	SoundPlayer(withSound: NSDataAsset(name: .init("drum1"))!.data),
	SoundPlayer(withSound: NSDataAsset(name: .init("drum1"))!.data),
	
	SoundPlayer(withSound: NSDataAsset(name: .init("drum2"))!.data),
	SoundPlayer(withSound: NSDataAsset(name: .init("drum2"))!.data),
	SoundPlayer(withSound: NSDataAsset(name: .init("drum2"))!.data),
]
let midiSender = try! MidiSender(name: "Magic Drumpad")
let midiDrummers = [
    MidiPlayer(note: 36, sender: midiSender),
    MidiPlayer(note: 40, sender: midiSender),
    MidiPlayer(note: 42, sender: midiSender),
	MidiPlayer(note: 46, sender: midiSender),
	
	MidiPlayer(note: 48, sender: midiSender),
	MidiPlayer(note: 47, sender: midiSender),
	MidiPlayer(note: 41, sender: midiSender),
	
	MidiPlayer(note: 49, sender: midiSender),
	MidiPlayer(note: 57, sender: midiSender),
	MidiPlayer(note: 51, sender: midiSender),
]
var drummers: [Player] = midiDrummers
var ccMode = false;
var midiMode = false;

extension Notification.Name {
	static let settingsDidChange = Notification.Name("settingsDidChange")
}

func loadSettings() {
	// Load settings from UserDefaults or your model
	ccMode = UserDefaults.standard.bool(forKey: "ccMode")
	
	midiMode = UserDefaults.standard.bool(forKey: "midiMode")
	if midiMode {
		drummers = midiDrummers;
	} else {
		drummers = soundDrummers;
	}
	
	NotificationCenter.default.post(name: .settingsDidChange, object: nil)
}

func setMidiMode(value: Bool) {
	midiMode = value;
	
	if midiMode {
		drummers = midiDrummers
	} else {
		drummers = soundDrummers
	}
	UserDefaults.standard.set(midiMode, forKey: "midiMode")
	NotificationCenter.default.post(name: .settingsDidChange, object: nil)
}

func setCCMode(value: Bool) {
	ccMode = value
	UserDefaults.standard.set(ccMode, forKey: "ccMode")
	NotificationCenter.default.post(name: .settingsDidChange, object: nil)
}

class SettingsController: NSViewController {
	@IBOutlet weak var midiSwitch: NSButton!
	@IBOutlet weak var ccSwitch: NSButton!

	func updateSwitches() {
		midiSwitch.state = if (midiMode) { .on } else { .off }
		ccSwitch.state = if (ccMode) { .on } else { .off }
	}
	
	override func viewWillAppear() {
		super.viewWillAppear()
		loadSettings()
		updateSwitches()
	}
	
	@IBAction func changeOutput(_ sender: NSButton) {
		if sender == midiSwitch {
			setMidiMode(value: sender.state == .on)
		}
		if sender == ccSwitch {
			setCCMode(value: ccSwitch.state == .on)
		}
	}
	
}
