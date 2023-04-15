//
//  GameAnimationEffect.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 09/04/23.
//

import Foundation

struct GameAnimationEffect: Codable {
    
    init(id: Int, name: String, frames: [String]) {
        self.id = id
        self.name = name
        self.frames = frames
    }
    
    let id: Int
    let name: String
    let frames: [String]
}


extension GameAnimationEffect {
    
    /// Returns all the game animation effects.
//    static var all: [GameAnimationEffect]? {
//        try? Bundle.main.decodeJSON(GameConfiguration.jsonKey.animationEffects)
//    }
    
//    static func get(id: Int, name: String) -> GameAnimationEffect? {
//        let animationEffect = GameAnimationEffect.all?.first(where: { $0.name == name && $0.id == id })
//        return animationEffect
//    }
}
