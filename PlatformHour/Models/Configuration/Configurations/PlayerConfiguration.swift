//
//  PlayerConfiguration.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 17/03/23.
//

import Foundation

struct PlayerConfiguration {
    
    init() { }
    
    // MARK: - Stats
    let range: CGFloat = 5
    let attackSpeed: CGFloat = 0.5
    let movementSpeed: Int = 1
    let jumpValue: CGFloat = 1
    let fallSpeed: CGFloat = 1000
    
    // MARK: - Frames
    let runTimePerFrame: TimeInterval = 0.04
    let hitTimePerFrame: TimeInterval = 0.05
    let deathTimePerFrame: TimeInterval = 0.05
}
