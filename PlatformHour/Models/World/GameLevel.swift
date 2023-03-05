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
    var requirement: Int
    let exitCoordinate: Int
}

extension GameLevel {
    
    enum GameLevelError: String, Error {
        case levelNotFound
    }
    
    static var all: [GameLevel] { try! Bundle.main.decodeJSON("levels.json") }
    static func get(_ id: Int) throws -> GameLevel {
        let level = GameLevel.all.first(where: { $0.id == id })
        if let level = level { return level }
        throw GameLevelError.levelNotFound.rawValue
    }
}
