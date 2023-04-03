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
    let playerCoordinate: String
    let background: String
    let exit: LevelExit
    let structures: [LevelStructure]
    let obstacles: [LevelObstacles]
    let containers: [GameObjectContainer]
    let traps: [LevelTrap]
    let npcs: [LevelNPC]
    let enemies: [LevelEnemy]
    let gems: [LevelGem]
}

extension GameLevel {
    
    static var all: [GameLevel]? {
        try? Bundle.main.decodeJSON(GameConfiguration.jsonConfigurationKey.levels)
    }
    
    static func get(_ id: Int) -> GameLevel? {
        let level = GameLevel.all?.first(where: {
            $0.id == id
        })
        return level
    }
}
