//
//  SliderBox.swift
//  Magic Drumpad
//
//  Created by r00tman on 06/09/2025.
//  Copyright © 2025 r00tman. All rights reserved.
//

import Cocoa

class SliderBox: NSView {
	var percent: CGFloat = 0.5 { // 0.0 – 1.0
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
		
		// --- Fill ---
		let clamped = min(max(percent, 0), 1)
		let fillHeight = rect.height * clamped
		let fillRect = CGRect(x: rect.minX,
							  y: rect.minY,
							  width: rect.width,
							  height: fillHeight)
		
		fillColor.setFill()
		fillRect.fill()
		
		// --- Stroke border (optional, on top) ---
		borderColor.setStroke()
		clipPath.lineWidth = 1
		clipPath.stroke()
	}
}
