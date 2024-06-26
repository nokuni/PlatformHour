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
    let mapZPosition: CGFloat = 0
    let backgroundZPosition: CGFloat = 1
    let betweenBackAndSceneZPosition: CGFloat = 2
    let sceneryZPosition: CGFloat = 3
    let NPCZPosition: CGFloat = 4
    let objectZPosition: CGFloat = 5
    let overObjectZPosition: CGFloat = 6
    let playerZPosition: CGFloat = 7
    let overPlayerZPosition: CGFloat = 8
    let animationZPosition: CGFloat = 9
    let hudLayerZPosition: CGFloat = 10
    let hudZPosition: CGFloat = 11
    let elementHUDZPosition: CGFloat = 12
    let overElementHUDZPosition: CGFloat = 13
    let screenFilterZPosition: CGFloat = 14
    
    // MARK: - Camera
    let cameraZoom = UIDevice.isOnPhone ? 1.1 : 1.25
    let cameraCatchUpDelay: CGFloat = 0.05
    let cameraAdjustement: CGFloat = UIDevice.isOnPhone ?
    (CGSize.screen.height * 0.2) :
    (CGSize.screen.height * 0.3)
    
    // MARK: - Map
    let tileSize = UIDevice.isOnPhone ?
    CGSize(width: CGSize.screen.height * 0.15, height: CGSize.screen.height * 0.15) :
    CGSize(width: CGSize.screen.width * 0.07, height: CGSize.screen.width * 0.07)
    
    // MARK: - Objects
    var objectCollisionSizeTailoring: CGFloat { -tileSize.width * 0.5 }
    
    // MARK: - Sound
    let textTypingVolume: Float = 0.2
    let soundStepVolume: Float = 0.2
    let soundFallVolume: Float = 0.3
    let soundBackgroundVolume: Float = 0.1
    
    // MARK: - Text
    
    let titleFont: String = "Daydream"
    let textFont: String = "Outline Pixel7 Solid"
    
    // MARK: - Logic
    
    let addActionDelay: CGFloat = 0.1
}
