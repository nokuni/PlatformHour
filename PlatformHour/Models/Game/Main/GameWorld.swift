//
//  GameWorld.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 10/02/23.
//

import Foundation
import PlayfulKit

public struct GameWorld: Codable {
    public init(id: Int,
                name: String,
                levelIDs: [Int],
                playerLandSound: String) {
        self.id = id
        self.name = name
        self.levelIDs = levelIDs
        self.playerLandSound = playerLandSound
    }
    
    public let id: Int
    public let name: String
    public let levelIDs: [Int]
    public let playerLandSound: String
}

public extension GameWorld {
    
    static var all: [GameWorld]? {
        try? Bundle.main.decodeJSON(GameConfiguration.jsonKey.worlds)
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
