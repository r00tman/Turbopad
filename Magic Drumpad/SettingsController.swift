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

enum PadMode: String, CaseIterable {
	case drums = "Drums"
	case cc = "CC"
	case guitar = "Guitar"
}

var padMode = PadMode.drums;
var midiMode = false;

extension Notification.Name {
	static let settingsDidChange = Notification.Name("settingsDidChange")
}

func loadSettings() {
	// Load settings from UserDefaults or your model
	padMode = PadMode(rawValue: UserDefaults.standard.string(forKey: "padMode") ?? PadMode.drums.rawValue) ?? PadMode.drums
	
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

func setPadMode(value: PadMode) {
	padMode = value
	UserDefaults.standard.set(padMode.rawValue, forKey: "padMode")
	NotificationCenter.default.post(name: .settingsDidChange, object: nil)
}

class SettingsController: NSViewController {
	@IBOutlet weak var midiSwitch: NSButton!
	@IBOutlet weak var modeCombo: NSComboBox!

	func updateSwitches() {
		midiSwitch.state = if (midiMode) { .on } else { .off }
		modeCombo.stringValue = padMode.rawValue
	}
	
	override func viewWillAppear() {
		super.viewWillAppear()
		modeCombo.removeAllItems()
		modeCombo.addItems(withObjectValues: PadMode.allCases.map { $0.rawValue })
		loadSettings()
		updateSwitches()
	}
	
	@IBAction func changeOutput(_ sender: NSButton) {
		if sender == midiSwitch {
			setMidiMode(value: sender.state == .on)
		}

	}
	
	@IBAction func changeMode(_ sender: NSComboBox) {
		let selectedString = modeCombo.stringValue;
		if let val = PadMode(rawValue: selectedString) {
			setPadMode(value: val)
		}
	}
}
