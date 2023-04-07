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
    let mapMatrix: String
    let playerCoordinate: String
    let background: String
    let musics: [String]
    let exit: LevelExit
    let structures: [LevelStructure]
    let containers: [LevelContainer]
    let traps: [LevelTrap]
    let npcs: [LevelNPC]
    let enemies: [LevelEnemy]
    let gems: [LevelGem]
    let dialogs: [LevelDialog]
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
