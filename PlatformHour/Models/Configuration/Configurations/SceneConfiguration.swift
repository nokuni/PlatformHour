//
//  SceneConfiguration.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 06/04/23.
//

import Foundation
import SwiftUI

struct SceneConfiguration {
    
    // MARK: - ZPositions
    let backgroundZPosition: CGFloat = 1
    let sceneryZPosition: CGFloat = 2
    let NPCZPosition: CGFloat = 3
    let objectZPosition: CGFloat = 4
    let playerZPosition: CGFloat = 4
    let hudZPosition: CGFloat = 5
    let elementHUDZPosition: CGFloat = 6
    let overlayZPosition: CGFloat = 7
    let overOverlayZPosition: CGFloat = 8
    
    // MARK: - Camera
    let cameraZoom = UIDevice.isOnPhone ? 1.1 : 1.25
    let cameraCatchUpDelay: CGFloat = 0
    let cameraAdjustement: CGFloat = UIDevice.isOnPhone ?
    (CGSize.screen.height * 0.2) :
    (CGSize.screen.height * 0.3)
    
    // MARK: - Map
    let tileSize = UIDevice.isOnPhone ?
    CGSize(width: CGSize.screen.height * 0.15, height: CGSize.screen.height * 0.15) :
    CGSize(width: CGSize.screen.width * 0.07, height: CGSize.screen.width * 0.07)
}
