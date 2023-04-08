//
//  GameObjectAnimation.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 15/03/23.
//

import Foundation

public struct GameObjectAnimation: Codable {
    
    public init(identifier: String, frames: [String]) {
        self.identifier = identifier
        self.frames = frames
    }
    
    public var identifier: String
    public var frames: [String]
}
