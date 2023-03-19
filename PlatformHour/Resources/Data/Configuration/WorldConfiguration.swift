//
//  WorldConfiguration.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 17/03/23.
//

import SwiftUI

struct WorldConfiguration {
    let gravity = CGVector(dx: 0, dy: -10)
    let cameraZoom = UIDevice.isOnPhone ? 3 : 1.25
    let cameraCatchUpDelay: CGFloat = 0
    let cameraAdjustement: CGFloat = UIDevice.isOnPhone ?
    (CGSize.screen.height * 0.2) :
    (CGSize.screen.height * 0.3)
    let tileSize = UIDevice.isOnPhone ?
    CGSize(width: CGSize.screen.height * 0.15, height: CGSize.screen.height * 0.15) :
    CGSize(width: CGSize.screen.width * 0.07, height: CGSize.screen.width * 0.07)
    let soundSFXVolume: Float = 0.1
}
