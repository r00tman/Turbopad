//
//  ViewController.swift
//  Magic Drumpad
//
//  Created by Damiaan on 18/06/17.
//  Copyright © 2017 Damiaan Dufaux. All rights reserved.
//

import Cocoa
import M5MultitouchSupport
import HotKey

let escape = "\u{1b}"

class TrackpadController: NSViewController {
	@IBOutlet weak var page_view: NSView!
	
	@IBOutlet weak var fingerView1: NSBox!
	@IBOutlet weak var fingerView2: NSBox!
	@IBOutlet weak var fingerView3: NSBox!
	@IBOutlet weak var fingerView4: NSBox!
	@IBOutlet weak var fingerView5: NSBox!

	@IBOutlet weak var lockButton: NSButton!
	
	@IBOutlet weak var disabledLabel: NSView!;
	@IBOutlet weak var statusLabel: NSTextField!;
	
	var touchListener: M5MultitouchListener?
	var fingerSize: CGFloat {
		get {
			self.fingerView1.bounds.width
		}
	}
	var fingerViews: Set<NSBox>!
	var visibleFingers = [Int32: NSBox]()
	
	var pageHandler: PageHandler?
	
	var hotKeyToggle: HotKey?;
	var hotKeyMode: HotKey?;
	var hotKeyLock: HotKey?;
	var hotKeyPBAbs: HotKey?;
	var hotKeyXYAbs: HotKey?;
	var hotKeyXYReset: HotKey?;
	
	var isDisabled: Bool = false;
	
	override func viewDidLoad() {
		super.viewDidLoad()
		touchListener = M5MultitouchManager.shared()?.addListener(callback: touchHandler)
		fingerViews = [fingerView1, fingerView2, fingerView3, fingerView4, fingerView5]
		
		view.allowedTouchTypes = [.direct, .indirect]
		view.wantsRestingTouches = true
		view.pressureConfiguration = NSPressureConfiguration(pressureBehavior: .primaryClick)
		
		loadSettings()
		updateUI()
		
		hotKeyToggle = HotKey(key: .f9, modifiers: [.command, .shift], keyDownHandler: {
			self.isDisabled = !self.isDisabled;
			self.updateUI();
		})
		
		hotKeyLock = HotKey(key: .f8, modifiers: [.command, .shift], keyDownHandler: {
			NSApp.activate(ignoringOtherApps: true)
			self.lockButton.performClick(self.lockButton)
		})
		
		hotKeyMode = HotKey(key: .f7, modifiers: [.command, .shift], keyDownHandler: {
			let modes = PadMode.allCases
			let idx = modes.firstIndex(of: padMode)!
			let nextIdx = (idx+1) % modes.count
			let nextMode = modes[nextIdx]
			
			setPadMode(value: nextMode)
		})
		
		hotKeyPBAbs = HotKey(key: .f10, modifiers: [.command, .shift], keyDownHandler: {
			if padMode != .cc {
				return;
			}
			let cch = self.pageHandler as! CCPageHandler?
			cch!.sliderAbsMode = !cch!.sliderAbsMode
			self.updateStatus()
		})
		
		hotKeyXYAbs = HotKey(key: .f11, modifiers: [.command, .shift], keyDownHandler: {
			if padMode != .cc {
				return;
			}
			let cch = self.pageHandler as! CCPageHandler?
			cch!.modAbsMode = !cch!.modAbsMode
			self.updateStatus()
		})
		
		hotKeyXYReset = HotKey(key: .f12, modifiers: [.command, .shift], keyDownHandler: {
			if padMode != .cc {
				return;
			}
			let cch = self.pageHandler as! CCPageHandler?
			cch!.modAutoReset = !cch!.modAutoReset
			self.updateStatus()
		})
		
		
		NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: .settingsDidChange, object: nil)
	}
	
	func updateStatus() {
		var res = ""
		switch padMode {
		case .cc:
			res += "CC Mode"
			
			let cch = pageHandler as! CCPageHandler?;
			
			if cch!.sliderAbsMode {
				res += " | PB Abs Mode"
			} else {
				res += " | PB Rel Mode"
			}
			
			if cch!.modAbsMode {
				res += " | Mod XY Abs Mode"
			} else {
				res += " | Mod XY Rel Mode"
			}
			
			if cch!.modAutoReset {
				res += " | Mod XY Auto Reset ON"
			} else {
				res += " | Mod XY Auto Reset OFF"
			}
		case .drums:
			res += "Pad Mode"
		case .guitar:
			res += "Guitar Mode"
		}
		
		statusLabel.stringValue = res
	}

	@objc func updateUI() {
		switch padMode {
		case .cc:
			if !(self.pageHandler is CCPageHandler) {
				self.pageHandler = CCPageHandler()
				self.page_view.subviews.removeAll();
				self.pageHandler?.setup(container: self.page_view)
			}
		case .drums:
			if !(self.pageHandler is PadPageHandler) {
				self.pageHandler = PadPageHandler()
				self.page_view.subviews.removeAll();
				self.pageHandler?.setup(container: self.page_view)
			}
		case .guitar:
			self.page_view.subviews.removeAll();
		}
		disabledLabel.isHidden = !isDisabled
		self.updateStatus()
	}
	
	func touchHandler(event: M5MultitouchEvent?) {
		if isDisabled {
			return;
		}
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
		self.pageHandler?.touchBegan(touch: touch)
		
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
		self.pageHandler?.touchMoved(touch: touch)
		
		if let fingerView = visibleFingers[touch.identifier] {
			fingerView.frame.origin.x = (view.frame.width - fingerSize) * CGFloat(touch.posX)
			fingerView.frame.origin.y = (view.frame.height - fingerSize) * CGFloat(touch.posY)
		}
	}
	
	func touchEnded(touch: M5MultitouchTouch) {
		self.pageHandler?.touchEnded(touch: touch)
		
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
		NotificationCenter.default.removeObserver(self)
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
