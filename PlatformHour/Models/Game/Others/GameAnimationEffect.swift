//
//  GameAnimationEffect.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 09/04/23.
//

import Foundation

struct GameAnimationEffect: Codable {
    let id: Int
    let name: String
    let frames: [String]
}


extension GameAnimationEffect {
    
    static var all: [GameAnimationEffect]? {
        try? Bundle.main.decodeJSON(GameConfiguration.jsonKey.animationEffects)
    }
    
    static func get(id: Int, name: String) -> GameAnimationEffect? {
        let animationEffect = GameAnimationEffect.all?.first(where: { $0.name == name && $0.id == id })
        return animationEffect
    }
}
