//
//  Utils.swift
//  Turbopad
//
//  Created by r00tman on 06/09/2025.
//  Copyright © 2025 r00tman. All rights reserved.
//

import Cocoa

func -(left: CGPoint, right: CGPoint) -> CGSize {
	return CGSize(
		width: left.x - right.x,
		height: left.y - right.y
	)
}

func -(left: CGSize, right: CGSize) -> CGSize {
	return CGSize(
		width: left.width - right.width,
		height: left.height - right.height
	)
}

func +(left: CGPoint, right: CGSize) -> CGPoint {
	return CGPoint(
		x: left.x + right.width,
		y: left.y + right.height
	)
}

func *(left: CGSize, right: CGFloat) -> CGSize {
	return CGSize(
		width: left.width * right,
		height: left.height * right
	)
}
