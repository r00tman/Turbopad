//
//  PadPageHandler.swift
//  Magic Drumpad
//
//  Created by r00tman on 06/09/2025.
//  Copyright © 2025 r00tman. All rights reserved.
//

import Cocoa
import M5MultitouchSupport

class PadPageHandler: PageHandler {
	var container: NSView!
	let gridData: [CGRect] = [
		CGRect(x: 0.00, y: 0.00, width: 0.33, height: 1.00),
		CGRect(x: 0.33, y: 0.00, width: 0.33, height: 1.00),
		CGRect(x: 0.66, y: 0.50, width: 0.33, height: 0.50),
		CGRect(x: 0.66, y: 0.00, width: 0.33, height: 0.50)
	]
	
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
		self.hitAnimation.fromValue = #colorLiteral(red: 0, green: 0.2220619044, blue: 0.4813616071, alpha: 0.3024042694).cgColor
		self.hitAnimation.toValue = CGColor(gray: 0.5, alpha: 0)
		self.hitAnimation.duration = 0.2
		self.hardHitAnimation.fromValue = #colorLiteral(red: 0.7373046875, green: 0, blue: 0, alpha: 0.5850022007).cgColor
		self.hardHitAnimation.toValue = NSColor.quaternaryLabelColor.cgColor
		self.hardHitAnimation.duration = 0.2
		
		for data in gridData {
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
	
	func drummer(at point: CGPoint) -> Int {
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
	
	func drummer(at point: (x: Float, y: Float)) -> Int {
		let point = CGPoint(x: CGFloat(point.x), y: CGFloat(point.y))
		return drummer(at: point)
	}
	
	func touchBegan(touch: M5MultitouchTouch) {
		let size = min(touch.size, 2.5) / 2.5
		let drummerIndex = drummer(at: (touch.posX, touch.posY))
		if (drummerIndex >= 0) {
			drummers[drummerIndex].play(velocity: size)
			
			DispatchQueue.main.async {
				self.boxes[drummerIndex].layer?.add(size>0.8 ? self.hardHitAnimation:self.hitAnimation, forKey: "backgroundColor")
			}
		}
	}
	
	func touchMoved(touch: M5MultitouchTouch) {
	}
	
	func touchEnded(touch: M5MultitouchTouch) {
		let index = drummer(at: (touch.posX, touch.posY))
		if (index >= 0) {
			drummers[index].stop()
		}
	}
}
