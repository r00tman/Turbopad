//
//  PadPageHandler.swift
//  Turbopad
//
//  Created by r00tman on 06/09/2025.
//  Copyright © 2025 r00tman. All rights reserved.
//

import Cocoa
import M5MultitouchSupport

protocol PageHandler {
	func setup(container: NSView)
	func touchBegan(touch: M5MultitouchTouch)
	func touchMoved(touch: M5MultitouchTouch)
	func touchEnded(touch: M5MultitouchTouch)
}
