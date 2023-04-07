//
//  WorldConfiguration.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 17/03/23.
//

import SwiftUI
import PlayfulKit

struct WorldConfiguration {
    let cameraZoom = UIDevice.isOnPhone ? 1.1 : 1.25
    let cameraCatchUpDelay: CGFloat = 0
    let cameraAdjustement: CGFloat = UIDevice.isOnPhone ?
    (CGSize.screen.height * 0.2) :
    (CGSize.screen.height * 0.3)
    let tileSize = UIDevice.isOnPhone ?
    CGSize(width: CGSize.screen.height * 0.15, height: CGSize.screen.height * 0.15) :
    CGSize(width: CGSize.screen.width * 0.07, height: CGSize.screen.width * 0.07)
    
//    let leftBoundaryLimit: Int = 8
//    let rightBoundaryLimit: Int = 51
//    let topBoundaryLimit: Int = 4
//    let bottomBoundaryLimit: Int = 34
    
//    let xDeathBoundary: Int = 39
}
