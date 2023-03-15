//
//  GameLevel.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import Foundation
import PlayfulKit

struct GameLevel: Codable {
    let id: Int
    let playerCoordinate: Int
    var statue: GameStatue
    let containers: [GameObjectContainer]
}

extension GameLevel {
    
    static var all: [GameLevel]? {
        try? Bundle.main.decodeJSON(GameApp.jsonConfigurationKey.levels)
    }
    
    static func get(_ id: Int) -> GameLevel? {
        let level = GameLevel.all?.first(where: {
            $0.id == id
        })
        return level
    }
}
