//
//  SliderBox.swift
//  Turbopad
//
//  Created by r00tman on 06/09/2025.
//  Copyright © 2025 r00tman. All rights reserved.
//

import Cocoa

class SliderBox: NSView {
	var percent: CGFloat = 0.5 { // 0.0 – 1.0
		didSet { needsDisplay = true }
	}
	
	var cornerRadius: CGFloat = 2
	var fillColor: NSColor = #colorLiteral(red: 0, green: 0.2220619044, blue: 0.4813616071, alpha: 0.3024042694)
	var backgroundColor: NSColor = .quaternaryLabelColor.withAlphaComponent(0.01)
	var borderColor: NSColor = .secondaryLabelColor
	var borderWidth: CGFloat = 2
	
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
		clipPath.lineWidth = borderWidth
		clipPath.stroke()
	}
}
