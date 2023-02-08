//
//  GameCharacter.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 31/01/23.
//

import SpriteKit

struct GameCharacter: Codable {
    let id: String
    var sprites: String
    
    var node = SKSpriteNode()
    
    enum CodingKeys: String, CodingKey {
        case id
        case sprites
    }
}

extension GameCharacter {
    
    enum GameCharacterError: String, Error {
        case noGameCharacterFound = "No game character found in data"
    }
    
    static let all: [GameCharacter] = try! Bundle.main.decode("gameCharacters.json")
    
    static func get(_ id: String) throws -> GameCharacter {
        if let gameCharacter = GameCharacter.all.first(where: { $0.id == id }) {
            return gameCharacter
        }
        throw GameCharacterError.noGameCharacterFound.rawValue
    }
}
