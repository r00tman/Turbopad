//
//  ViewController.swift
//  Magic Drumpad
//
//  Created by Damiaan on 18/06/17.
//  Copyright © 2017 Damiaan Dufaux. All rights reserved.
//

import Cocoa
import M5MultitouchSupport

let escape = "\u{1b}"

class TrackpadController: NSViewController {
	@IBOutlet weak var page_view: NSView!
	
	@IBOutlet weak var fingerView1: NSBox!
	@IBOutlet weak var fingerView2: NSBox!
	@IBOutlet weak var fingerView3: NSBox!
	@IBOutlet weak var fingerView4: NSBox!
	@IBOutlet weak var fingerView5: NSBox!

	@IBOutlet weak var lockButton: NSButton!
	
	var touchListener: M5MultitouchListener?
	var fingerSize: CGFloat {
		get {
			self.fingerView1.bounds.width
		}
	}
	var fingerViews: Set<NSBox>!
	var visibleFingers = [Int32: NSBox]()
	
	var page_handler: PageHandler?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		touchListener = M5MultitouchManager.shared()?.addListener(callback: touchHandler)
		fingerViews = [fingerView1, fingerView2, fingerView3, fingerView4, fingerView5]
		
		view.allowedTouchTypes = [.direct, .indirect]
		view.wantsRestingTouches = true
		view.pressureConfiguration = NSPressureConfiguration(pressureBehavior: .primaryClick)
		
		self.page_handler = CCPageHandler()
//		self.page_handler = PadPageHandler()
		self.page_handler?.setup(container: self.page_view)
	}
	
	func touchHandler(event: M5MultitouchEvent?) {
		for object in event!.touches {
			let touch = object as! M5MultitouchTouch
			switch touch.state {
				case .making: touchBegan(touch: touch)
				case .touching: DispatchQueue.main.async{ self.touchMoved(touch: touch) }
				case .leaving: DispatchQueue.main.async{ self.touchEnded(touch: touch) }
				default: break
			}
		}
	}
	
	func touchBegan(touch: M5MultitouchTouch) {
		self.page_handler?.touchBegan(touch: touch)
		
		DispatchQueue.main.async {
			let x = (self.view.frame.width - self.fingerSize) * CGFloat(touch.posX)
			let y = (self.view.frame.height - self.fingerSize) * CGFloat(touch.posY)
			
			if let fingerView = self.fingerViews.subtracting(self.visibleFingers.values).first {
				self.visibleFingers[touch.identifier] = fingerView
				fingerView.isTransparent = false
				
				fingerView.frame.origin.x = x
				fingerView.frame.origin.y = y
			}
		}
	}
	
	func touchMoved(touch: M5MultitouchTouch) {
		self.page_handler?.touchMoved(touch: touch)
		
		if let fingerView = visibleFingers[touch.identifier] {
			fingerView.frame.origin.x = (view.frame.width - fingerSize) * CGFloat(touch.posX)
			fingerView.frame.origin.y = (view.frame.height - fingerSize) * CGFloat(touch.posY)
		}
	}
	
	func touchEnded(touch: M5MultitouchTouch) {
		self.page_handler?.touchEnded(touch: touch)
		
		if let box = visibleFingers.removeValue(forKey: touch.identifier) {
			hide(fingerBox: box)
		}
	}
	
	func hide(fingerBox: NSBox) {
		fingerBox.isTransparent = true
	}
	
	@IBAction func lockMouse(_ sender: NSButton) {
		if sender.state == NSControl.StateValue.on {
			lockMouse()
		} else {
			unlockMouse()
		}
	}
	
	var mousePosition = CGPoint.zero
	
	func lockMouse() {
		CGDisplayHideCursor(.init(0))
		CGAssociateMouseAndMouseCursorPosition(0)
		mousePosition = view.window?.convertToGlobal( NSEvent.mouseLocation ) ?? .zero
		CGWarpMouseCursorPosition(CGPoint(
			x: NSEvent.mouseLocation.x,
			y: view.window?.convertToGlobal(
				view.window?.convertToScreen(
					view.convert(lockButton.frame, to: nil)
				).origin ?? .zero
			)?.y ?? 100
		))
		lockButton.keyEquivalent = escape
		lockButton.title = "Press escape to unlock mouse"
	}
	
	func unlockMouse() {
		CGWarpMouseCursorPosition(mousePosition)
		CGDisplayShowCursor(.init(0))
		CGAssociateMouseAndMouseCursorPosition(1)
		lockButton.title = "Lock mouse"
		lockButton.keyEquivalent = ""
	}
	
	deinit {
		M5MultitouchManager.shared()?.remove(touchListener)
	}
}

extension NSWindow {
	func convertToGlobal(_ point: CGPoint) -> CGPoint? {
		if let screen = screen {
			return CGPoint(
				x: point.x,
				y: screen.frame.maxY - point.y
			)
		} else {
			return nil
		}
	}
}
