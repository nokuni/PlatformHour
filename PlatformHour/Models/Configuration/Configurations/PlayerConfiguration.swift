//
//  PlayerConfiguration.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 17/03/23.
//

import Foundation

public struct PlayerConfiguration {
    
    public init() { }
    
    // MARK: - Stats
    public let range: CGFloat = 5
    public let attackSpeed: CGFloat = 0.5
    public let movementSpeed: Int = 1
    public let jumpValue: CGFloat = 1
    public let fallSpeed: CGFloat = 1000
    
    // MARK: - Frames
    public let runTimePerFrame: TimeInterval = 0.04
    public let hitTimePerFrame: TimeInterval = 0.05
    public let deathTimePerFrame: TimeInterval = 0.05
}
