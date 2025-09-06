//
//  XYBox.swift
//  Magic Drumpad
//
//  Created by r00tman on 06/09/2025.
//  Copyright © 2025 r00tman. All rights reserved.
//

import Cocoa

class XYBox: NSView {
	var value: (x: CGFloat, y: CGFloat) = (0.0, 0.0) { // 0.0 – 1.0
		didSet { needsDisplay = true }
	}
	
	var cornerRadius: CGFloat = 4
	var fillColor: NSColor = .systemBlue
	var backgroundColor: NSColor = .windowBackgroundColor
	var borderColor: NSColor = .secondaryLabelColor;
	
	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		
		let rect = bounds
		
		// --- Rounded container path ---
		let clipPath = NSBezierPath(roundedRect: rect,
									xRadius: cornerRadius,
									yRadius: cornerRadius)
		
		// Clip everything to rounded rect
		clipPath.addClip()
		
		// --- Background ---
		backgroundColor.setFill()
		rect.fill()
		
		// --- Indicator ---
		let indicatorSize: CGFloat = 10 // Size of the indicator
		let indicatorX = rect.minX + value.x * rect.width - indicatorSize / 2
		let indicatorY = rect.minY + value.y * rect.height - indicatorSize / 2
		let indicatorRect = CGRect(x: indicatorX,
								   y: indicatorY,
								   width: indicatorSize,
								   height: indicatorSize)
		
		fillColor.setFill()
		let indicatorPath = NSBezierPath(ovalIn: indicatorRect) // Draw a circle as the indicator
		indicatorPath.fill()
		
		// --- Stroke border (optional, on top) ---
		borderColor.setStroke()
		clipPath.lineWidth = 1
		clipPath.stroke()
	}
}
