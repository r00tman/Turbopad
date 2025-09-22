//
//  PadPageHandler.swift
//  Turbopad
//
//  Created by r00tman on 06/09/2025.
//  Copyright © 2025 r00tman. All rights reserved.
//

import Cocoa
import M5MultitouchSupport

class GuitarPageHandler: PageHandler {
	var container: NSView!
	// 0,0 - bottom left
	var gridData: [(CGRect, Int)] = [
	]
	
	let NUM_STRINGS = 5
	let NUM_FRETS = 8

	var boxes = [NSBox]()
	
	let hitAnimation = CABasicAnimation()
	let hardHitAnimation = CABasicAnimation()
	
	
	func setup(container: NSView) {
		assert(self.container == nil) // only setup once, can't resetup yet
		self.container = container
		self.createGrid()
	}
	
	func convertPointToView(point: CGPoint) -> CGPoint {
		let viewPoint = CGPoint(x: point.x * container.bounds.width,
								y: point.y * container.bounds.height)
		return viewPoint
	}
	
	func convertRectToView(rect: CGRect) -> CGRect {
		let origin = convertPointToView(point: rect.origin)
		let dest = convertPointToView(point: rect.origin+rect.size)
		let size = dest-origin
		return CGRect(origin: origin, size: size)
	}
	
	func createGrid() {
		gridData.removeAll()
		let W = CGFloat(1) / CGFloat(NUM_FRETS)
		let H = CGFloat(1) / CGFloat(NUM_STRINGS)
		for string in 0..<NUM_STRINGS {
			let stringNote = 0 + 5 * string
			for fret in 0..<NUM_FRETS {
				let note = stringNote + fret
				gridData.append((CGRect(x: CGFloat(fret) * W, y: CGFloat(string) * H, width: W, height: H), note))
			}
		}
		
		self.hitAnimation.fromValue = #colorLiteral(red: 0, green: 0.2220619044, blue: 0.4813616071, alpha: 0.3024042694).cgColor
		self.hitAnimation.toValue = CGColor(gray: 0.5, alpha: 0)
		self.hitAnimation.duration = 0.2
		self.hardHitAnimation.fromValue = #colorLiteral(red: 0.7373046875, green: 0, blue: 0, alpha: 0.5850022007).cgColor
		self.hardHitAnimation.toValue = NSColor.quaternaryLabelColor.cgColor
		self.hardHitAnimation.duration = 0.2
		
		for (data, _) in gridData {
			let frame = convertRectToView(rect: data)
			let pad: CGFloat = 3
			let paddedFrame = frame.insetBy(dx: pad, dy: pad)

			let box = NSBox(frame: paddedFrame)
			box.wantsLayer = true
			box.boxType = .custom
			box.layer?.borderColor = NSColor.separatorColor.cgColor
			box.layer?.cornerRadius = 4
			box.layer?.backgroundColor = NSColor.quaternaryLabelColor.cgColor
			box.autoresizingMask = [.width, .height, .minXMargin, .minYMargin, .maxXMargin, .maxYMargin]
			
			self.container.addSubview(box)
			self.boxes.append(box)
		}
	}
	
	func box(at point: CGPoint) -> Int {
		// clamp to 0...1
		let nx = max(0, min(1, point.x))
		let ny = max(0, min(1, point.y))
		
		let clampedPoint = CGPoint(x: nx, y: ny)
		
		for (index, (box, _)) in gridData.enumerated().reversed() { // reversed() -> last in array considered frontmost change if different
			// Convert point from view's coordinate system into the box's coordinate system
			if box.contains(clampedPoint) {
				return index
			}
		}
		
		return -1 // not found
	}
	
	func box(at point: (x: Float, y: Float)) -> Int {
		let point = CGPoint(x: CGFloat(point.x), y: CGFloat(point.y))
		return box(at: point)
	}
	
	func midiNote(at boxIdx: Int) -> UInt8 {
		// let baseNote = 52 // E3
		let baseNote = guitarBaseNote
		let (_, noteRel) = self.gridData[boxIdx]
		let note = baseNote + noteRel
		return UInt8(note)
	}
	
	var touchesToNotes = ThreadSafeDictionary<Int32, (note: UInt8, touchX: Float, touchY: Float)>();
	var isPBing = Set<Int32>();
	
	var midiChannel: UInt8 = 0;
	
	var mpeMode = true; // use MPE (allocate new MIDI channel for each touch)
	var pbMode = true; // true - use pitch-bend, false - note off old note, note on new note
	var touchesToMPEChannels = ThreadSafeDictionary<Int32, UInt8>();
	let MPE_GLOBAL_CH: UInt8 = 0;
	let MPE_MEMBER_CH: [UInt8] = Array(1...15);
	var mpeChannelNoteCnt: [Int] = Array(repeating: 0, count: 16);
	private let mpeChannelQueue = DispatchQueue(label: "MPE Channel Queue",
												attributes: .concurrent)
	
	// MIDI PB is assumed to be within -12 to +12 semitones
	// -48 to +48 semitones for MPE
	var minPB: Float {
		get { if mpeMode { -48.0 } else { -12.0 } }
	}
	var maxPB: Float {
		get { if mpeMode { 48.0 } else { 12.0 } }
	}


	func findFreeMPEChannel() -> UInt8? {
		return mpeChannelQueue.sync {
			for ch in MPE_MEMBER_CH {
				if mpeChannelNoteCnt[Int(ch)] == 0 {
					return ch
				}
			}
			return nil
		}
	}
	
	func allocMPEChannel() -> UInt8? {
		return mpeChannelQueue.sync {
			for ch in MPE_MEMBER_CH {
				if mpeChannelNoteCnt[Int(ch)] == 0 {
					mpeChannelNoteCnt[Int(ch)] += 1;
					return ch
				}
			}
			return nil
		}
	}
	
	func freeMPEChannel(_ ch: UInt8) {
		return mpeChannelQueue.sync {
			assert(mpeChannelNoteCnt[Int(ch)] == 1);
			mpeChannelNoteCnt[Int(ch)] -= 1;
		}
	}
	
	func touchBegan(touch: M5MultitouchTouch) {
		let size = min(touch.size, 2.5) / 2.5
		let boxIdx = box(at: (touch.posX, touch.posY))
		if boxIdx < 0 {
			return;
		}
		let note = midiNote(at: boxIdx)
		
		let ch: UInt8 = if mpeMode {
			allocMPEChannel()!
		} else {
			midiChannel
		}
		
		touchesToNotes[touch.identifier] = (note: note, touchX: touch.posX, touchY: touch.posY);
		touchesToMPEChannels[touch.identifier] = ch;
		
		try! midiSender.sendNoteOnMessage(noteNumber: note, velocity: UInt8(size*127), channel: ch)
		DispatchQueue.main.async {
			self.boxes[boxIdx].layer?.add(size>0.8 ? self.hardHitAnimation:self.hitAnimation, forKey: "backgroundColor")
		}
	}
	
	func touchMoved(touch: M5MultitouchTouch) {
		if let (origNote, origTouchX, origTouchY) = touchesToNotes[touch.identifier] {
			let boxIdx = box(at: (touch.posX, touch.posY))
			if boxIdx < 0 {
				return;
			}
			
			let ch = if mpeMode {
				touchesToMPEChannels[touch.identifier]!
			} else {
				midiChannel
			}
			
			let newNote = midiNote(at: boxIdx)
			
			if pbMode {
				let diff = (touch.posX - origTouchX);
				let diffSemis = diff / Float(self.gridData[boxIdx].0.width);
				let pbPercent = (diffSemis-minPB)/(maxPB-minPB); // 0 to 1, 0=minPB, 1=maxPB
				let pbVal: Int16 = Int16((pbPercent * 16383) - 8192)
				if isPBing.contains(touch.identifier) || abs(diffSemis) > 0.1 {
					isPBing.insert(touch.identifier)
					try! midiSender.sendPitchBendMessage(value: pbVal, channel: ch)
				}
			} else {
				if newNote != origNote {
					let size = min(touch.size, 2.5) / 2.5
					
					// reuse same MPE channel
					try! midiSender.sendNoteOnMessage(noteNumber: newNote, velocity: UInt8(size*127), channel: ch)

					// todo: should note off be send after new note on? for legato to work
					try! midiSender.sendNoteOffMessage(noteNumber: origNote, velocity: UInt8(size*127), channel: ch)
					
					touchesToNotes[touch.identifier] = (newNote, origTouchX, origTouchY)
					DispatchQueue.main.async {
						self.boxes[boxIdx].layer?.add(size>0.8 ? self.hardHitAnimation:self.hitAnimation, forKey: "backgroundColor")
					}
				}
			}
		}
	}
	
	func touchEnded(touch: M5MultitouchTouch) {
		let id = touch.identifier;
		if let (note, _, _) = touchesToNotes[id] {
			let ch = if mpeMode {
				touchesToMPEChannels[id]!
			} else {
				midiChannel
			}
			try! midiSender.sendNoteOffMessage(noteNumber: note, velocity: 120, channel: ch)
			isPBing.remove(id)
			touchesToNotes.removeValue(forKey: id)
			if mpeMode {
				freeMPEChannel(ch)
			}
		}
	}
}
