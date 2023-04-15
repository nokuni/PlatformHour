//
//  GameObjectAnimation.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 15/03/23.
//

import Foundation

struct GameObjectAnimation: Codable {
    
    init(identifier: String, frames: [String]) {
        self.identifier = identifier
        self.frames = frames
    }
    
    var identifier: String
    var frames: [String]
}
