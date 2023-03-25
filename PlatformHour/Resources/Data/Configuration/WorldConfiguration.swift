//
//  WorldConfiguration.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 17/03/23.
//

import SwiftUI
import PlayfulKit

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
    let leftBoundaryLimit: Int = 8
    let rightBoundaryLimit: Int = 43
    let topBoundaryLimit: Int = 4
    let bottomBoundaryLimit: Int = 14
    let soundSFXVolume: Float = 0.1
    let backgroundZPosition: CGFloat = 1
    let sceneryZPosition: CGFloat = 2
    let NPCZPosition: CGFloat = 3
    let objectZPosition: CGFloat = 4
    let playerZPosition: CGFloat = 4
    let hudZPosition: CGFloat = 5
    let elementHUDZPosition: CGFloat = 6
    let overlayZPosition: CGFloat = 7
    let xDeathBoundary: Int = 20
}
