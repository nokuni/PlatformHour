//
//  GameSprite.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 15/03/23.
//

import Foundation

struct GameSpriteAnimation: Codable {
    let id: String
    let frames: [String]
}

extension GameSpriteAnimation {
    
    static var all: [GameSpriteAnimation]? {
        return try? Bundle.main.decodeJSON(GameConfiguration.jsonConfigurationKey.spriteAnimations)
    }
    
    static func get(_ id: String) -> GameSpriteAnimation? {
        let spriteAnimation = GameSpriteAnimation.all?.first(where: {
            $0.id == id
        })
        return spriteAnimation
    }
}
