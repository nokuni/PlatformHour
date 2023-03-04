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
    let levelIDs: [Int]
}

extension GameWorld {
    
    enum GameWorldError: String, Error {
        case worldNotFound
    }
    
    static var all: [GameWorld] { try! Bundle.main.decodeJSON("worlds.json") }
    static func get(_ name: String) throws -> GameWorld {
        let world = GameWorld.all.first(where: { $0.name == name })
        if let world = world { return world }
        throw GameWorldError.worldNotFound.rawValue
    }
    
    var ground: MapStructure { try! MapStructure.get(groundName) }
    var levels: [GameLevel] { levelIDs.map { try! GameLevel.get($0) } }
}
