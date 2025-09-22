//
//  SettingsController.swift
//  Turbopad
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
let midiSender = try! MidiSender(name: "Turbopad")
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
var guitarBaseNote = 52;

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
	
	guitarBaseNote = UserDefaults.standard.integer(forKey: "guitarBaseNote")
	if guitarBaseNote == 0 {
		guitarBaseNote = 52 // default value
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

func setGuitarBaseNote(value: Int) {
	guitarBaseNote = value
	UserDefaults.standard.set(guitarBaseNote, forKey: "guitarBaseNote")
	NotificationCenter.default.post(name: .settingsDidChange, object: nil)
}

func midiNoteToStr(note: Int) -> String?  {
	// e.g., 60 -> C4
	guard note >= 0 && note <= 127 else { return nil }
		
	let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
	let octave = (note / 12) - 1
	let noteName = notes[note % 12]

	return "\(noteName)\(octave)"
}

func strToMidiNote(str: String) -> Int? {
	// e.g., C4 -> 60
	let notePattern = "([A-G][#b]?)(\\d)"
	let regex = try! NSRegularExpression(pattern: notePattern, options: [])
	let nsString = str as NSString
	let results = regex.matches(in: str, options: [], range: NSRange(location: 0, length: nsString.length))
	
	guard let match = results.first else { return nil }
	
	let noteName = nsString.substring(with: match.range(at: 1))
	let octaveString = nsString.substring(with: match.range(at: 2))
	
	guard let octave = Int(octaveString) else { return nil }
	
	let notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
	guard let noteIndex = notes.firstIndex(of: noteName) else { return nil }
	
	return (octave + 1) * 12 + noteIndex
}

class SettingsController: NSViewController {
	@IBOutlet weak var midiSwitch: NSButton!
	@IBOutlet weak var modeCombo: NSComboBox!
	@IBOutlet weak var guitarBaseNoteCombo: NSComboBox!

	func updateSwitches() {
		midiSwitch.state = if (midiMode) { .on } else { .off }
		modeCombo.stringValue = padMode.rawValue
		guitarBaseNoteCombo.stringValue = (midiNoteToStr(note: guitarBaseNote)) ?? "E3"
	}
	
	override func viewWillAppear() {
		super.viewWillAppear()
		modeCombo.removeAllItems()
		modeCombo.addItems(withObjectValues: PadMode.allCases.map { $0.rawValue })
		
		guitarBaseNoteCombo.removeAllItems()
		// add all notes from 0 to 127 in string form, e.g., C4
		let maxNote = 127 - 5*5; // 5 semitons between strings, 5 strings
		let notes = (0...maxNote).map { midiNoteToStr(note: $0) ?? "" }
		guitarBaseNoteCombo.addItems(withObjectValues: notes)
		
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
	
	@IBAction func changeGuitarBaseNote(_ sender: NSComboBox) {
		let selectedNote = guitarBaseNoteCombo.stringValue;
		if let val = strToMidiNote(str: selectedNote) {
			print("Setting guitar base note to \(val) (\(selectedNote))")
			setGuitarBaseNote(value: val)
		}
	}
	
	@IBAction func octaveDownGuitarBaseNote(_ sender: NSButton) {
		if (guitarBaseNote - 12 <= 0) {
			return;
		}
		let newVal = guitarBaseNote - 12
		let newStr = midiNoteToStr(note: newVal)!
		setGuitarBaseNote(value: newVal)
		guitarBaseNoteCombo.stringValue = newStr
	}
	
	@IBAction func octaveUpGuitarBaseNote(_ sender: NSButton) {
		if (guitarBaseNote + 12 + 5*5 >= 127) {
			return;
		}
		let newVal = guitarBaseNote + 12
		let newStr = midiNoteToStr(note: newVal)!
		setGuitarBaseNote(value: newVal)
		guitarBaseNoteCombo.stringValue = newStr
	}
}
