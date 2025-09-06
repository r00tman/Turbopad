//
//  CCPageHandler.swift
//  Magic Drumpad
//
//  Created by r00tman on 06/09/2025.
//  Copyright © 2025 r00tman. All rights reserved.
//

import Cocoa
import M5MultitouchSupport

class CCPageHandler: PageHandler {
	var container: NSView!
	let gridData: [CGRect] = [
		CGRect(x: 0.00, y: 0.00, width: 0.25, height: 1.00),
		CGRect(x: 0.25, y: 0.00, width: 0.75, height: 1.00),
	]
	
	var slider: SliderBox?
	var mod: XYBox?
	
	var boxes = [NSView]()
	
	let activateAnimation = CABasicAnimation()
	let releaseAnimation = CABasicAnimation()
	
	var sliderTouchId: Int32 = -1
	var sliderInitialY: Float = 0.0
	var sliderInitialPercent: CGFloat = 0.0
	
	var sliderAbsMode: Bool = false
	
	var modTouchId: Int32 = -1
	var modInitialTouch: (x: Float, y: Float) = (0.0, 0.0)
	var modInitialValue: (x: CGFloat, y: CGFloat) = (0.0, 0.0)
	
	var modAbsMode: Bool = true
	var modAutoReset: Bool = false
	
	
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
		self.activateAnimation.fromValue = #colorLiteral(red: 0, green: 0.2220619044, blue: 0.4813616071, alpha: 0.3024042694).cgColor
		self.activateAnimation.toValue = CGColor(gray: 0.5, alpha: 0)
		self.activateAnimation.duration = 0.2
		self.releaseAnimation.fromValue = #colorLiteral(red: 0.7373046875, green: 0, blue: 0, alpha: 0.5850022007).cgColor
		self.releaseAnimation.toValue = NSColor.quaternaryLabelColor.cgColor
		self.releaseAnimation.duration = 0.2
		
		for (index, data) in gridData.enumerated() {
			let frame = convertRectToView(rect: data)
			let pad: CGFloat = 3
			let paddedFrame = frame.insetBy(dx: pad, dy: pad)

			let box: NSView
			
			if (index == 0) {
				let o = SliderBox(frame: paddedFrame)
				slider = o
				box = o
			} else {
				let o = XYBox(frame: paddedFrame)
				mod = o
				box = o
			}
			
			box.wantsLayer = true
			box.layer?.borderColor = NSColor.separatorColor.cgColor
			box.layer?.cornerRadius = 4
			box.layer?.backgroundColor = NSColor.quaternaryLabelColor.cgColor
			box.autoresizingMask = [.width, .height, .minXMargin, .minYMargin, .maxXMargin, .maxYMargin]
			
			self.container.addSubview(box)
			self.boxes.append(box)
		}
	}
	
	func element(at point: CGPoint) -> Int {
		// clamp to 0...1
		let nx = max(0, min(1, point.x))
		let ny = max(0, min(1, point.y))
		
		let clampedPoint = CGPoint(x: nx, y: ny)
		
		for (index, box) in gridData.enumerated().reversed() { // reversed() -> last in array considered frontmost change if different
			// Convert point from view's coordinate system into the box's coordinate system
			if box.contains(clampedPoint) {
				return index
			}
		}
		
		return -1 // not found
	}
	
	func element(at point: (x: Float, y: Float)) -> Int {
		let point = CGPoint(x: CGFloat(point.x), y: CGFloat(point.y))
		return element(at: point)
	}
	
	func sendSliderPB() {
		let percent: CGFloat = self.slider!.percent
		let value: Int16 = Int16((percent * 16383) - 8192)
		try! midiSender.sendPitchBendMessage(value: value)
	}

	func updateSlider(touchY: Float) {
		let bounds = self.gridData[0]
		let minY = bounds.minY
		let maxY = bounds.maxY
		let percent = max(0, min(maxY-minY, CGFloat(touchY)-minY))/(maxY-minY)
		updateSlider(percent: percent)
	}
	
	func updateSlider(touchDY: Float) {
		let bounds = self.gridData[0]
		let minY = bounds.minY
		let maxY = bounds.maxY
		let deltaPercent = CGFloat(touchDY)/(maxY-minY)
		let percent = sliderInitialPercent + deltaPercent
		updateSlider(percent: percent)
	}
	
	func updateSlider(percent: CGFloat) {
		self.slider?.percent = percent
		sendSliderPB()
	}
	
	var lastXVal: UInt8 = 0;
	var lastYVal: UInt8 = 0;
	
	func sendModCC() {
		let (x, y) = self.mod!.value
		
		let xVal = UInt8(x*127);
		let yVal = UInt8(y*127);
		
		if (yVal != lastYVal) {
			try! midiSender.sendMidiCCMessage(controllerNumber: 1, value: yVal);
		}
		if (xVal != lastXVal) {
			try! midiSender.sendMidiCCMessage(controllerNumber: 2, value: xVal);
		}
		
		lastXVal = xVal;
		lastYVal = yVal;
	}
	
	func updateMod(touchX: Float, touchY: Float) {
		let bounds = self.gridData[1]
		let x = max(0, min(bounds.maxX-bounds.minX, CGFloat(touchX)-bounds.minX))/(bounds.maxX-bounds.minX)
		let y = max(0, min(bounds.maxY-bounds.minY, CGFloat(touchY)-bounds.minY))/(bounds.maxY-bounds.minY)
		updateMod(value: (x, y))
	}
	
	func updateMod(touchDX: Float, touchDY: Float) {
		let bounds = self.gridData[1]
		let deltaX = CGFloat(touchDX)/(bounds.maxX-bounds.minX)
		let deltaY = CGFloat(touchDY)/(bounds.maxY-bounds.minY)
		let newValue = modInitialValue + (deltaX, deltaY)
		updateMod(value: newValue)
	}
	
	func updateMod(value: (x: CGFloat, y: CGFloat)) {
		self.mod?.value = value
		sendModCC()
	}
	
	func touchBegan(touch: M5MultitouchTouch) {
		let idx = element(at: (touch.posX, touch.posY))
		if (idx == 0 && self.sliderTouchId == -1) {
			self.sliderTouchId = touch.identifier
			if (self.sliderAbsMode) {
				DispatchQueue.main.async {
					self.updateSlider(touchY: touch.posY)
				}
			} else {
				self.sliderInitialY = touch.posY
				self.sliderInitialPercent = slider!.percent
			}
		}
		if (idx == 1 && self.modTouchId == -1) {
			self.modTouchId = touch.identifier
			if (self.modAbsMode) {
				DispatchQueue.main.async {
					self.updateMod(touchX: touch.posX, touchY: touch.posY)
				}
			} else {
				self.modInitialTouch = (touch.posX, touch.posY)
				self.modInitialValue = mod!.value
			}
		}
	}
	
	func touchMoved(touch: M5MultitouchTouch) {
		if (touch.identifier == sliderTouchId) {
			DispatchQueue.main.async {
				if (self.sliderAbsMode) {
					self.updateSlider(touchY: touch.posY)
				} else {
					self.updateSlider(touchDY: touch.posY - self.sliderInitialY)
				}
			}
		}
		if (touch.identifier == modTouchId) {
			DispatchQueue.main.async {
				if (self.modAbsMode) {
					self.updateMod(touchX: touch.posX, touchY: touch.posY)
				} else {
					self.updateMod(touchDX: touch.posX - self.modInitialTouch.x, touchDY: touch.posY - self.modInitialTouch.y)
				}
			}
		}
	}
	
	func touchEnded(touch: M5MultitouchTouch) {
		if (sliderTouchId == touch.identifier) {
			sliderTouchId = -1
			sliderInitialY = 0.0
			sliderInitialPercent = 0.0
			DispatchQueue.main.async {
				self.updateSlider(percent: 0.5)
			}
		}
		if (modTouchId == touch.identifier) {
			modTouchId = -1
			modInitialTouch = (0.0, 0.0)
			modInitialValue = (0.0, 0.0)
			if (modAutoReset) {
				DispatchQueue.main.async {
					self.updateMod(value: (0.0, 0.0))
				}
			}
		}
	}
}

func +(left: (x: CGFloat, y: CGFloat), right: (x: CGFloat, y: CGFloat)) -> (x: CGFloat, y: CGFloat) {
	return (left.x + right.x, left.y + right.y)
}
