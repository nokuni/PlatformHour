//
//  GameWorld.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 10/02/23.
//

import Foundation
import PlayfulKit
import UtilityToolbox

struct GameWorld: Codable {
    let id: Int
    let name: String
    let levelIDs: [Int]
    let playerLandSound: String
}

extension GameWorld {
    
    static var all: [GameWorld]? {
        try? GameConfiguration.bundleManager.decodeJSON(GameConfiguration.jsonKey.worlds)
    }
    
    static func get(_ id: Int) -> GameWorld? {
        let world = GameWorld.all?.first(where: { $0.id == id })
        return world
    }
    
    var levels: [GameLevel] {
        levelIDs.compactMap {
            GameLevel.get($0)
        }
    }
}
