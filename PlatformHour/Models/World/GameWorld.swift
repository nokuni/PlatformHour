//
//  GameWorld.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 10/02/23.
//

import Foundation
import PlayfulKit

struct GameWorld: Codable {
    let id: Int
    let name: String
    let skyName: String
    let groundName: String
    let cloudName: String
    let levelIDs: [Int]
}

extension GameWorld {
    
    static var all: [GameWorld]? {
        try? Bundle.main.decodeJSON(GameApp.jsonConfigurationKey.worlds)
    }
    
    static func get(_ name: String) -> GameWorld? {
        let world = GameWorld.all?.first(where: {
            $0.name == name
        })
        return world
    }
    
    var ground: MapStructure? {
        try? MapStructure.get(groundName)
    }
    
    var levels: [GameLevel] {
        levelIDs.compactMap {
            GameLevel.get($0)
        }
    }
}
