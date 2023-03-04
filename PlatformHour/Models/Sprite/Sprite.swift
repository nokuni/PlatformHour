//
//  Sprite.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 31/01/23.
//

import Foundation

struct Sprite: Codable {
    let id: String
    let name: String
    let state: State
    let amount: Int
    
    enum State: String, Codable {
        case idle, run
    }
}

extension Sprite {
    
    enum SpriteError: String, Error {
        case noSpriteFound = "No sprite found in data"
        case noGameCharacterFound = "No game character found in data"
    }
    
    static func all() throws -> [Sprite] {
        do {
            let sprites: [Sprite] = try Bundle.main.decodeJSON("sprites.json")
            return sprites
        } catch {
            throw SpriteError.noSpriteFound
        }
    }
    
    static func get(_ name: String, state: Sprite.State) throws -> Sprite {
        if let sprite = try Sprite.all().first(where: {
            $0.name == name && $0.state == state
        }) {
            return sprite
        }
        throw SpriteError.noSpriteFound.rawValue
    }
    
    static func getCharacter(from id: String) throws -> GameCharacter {
        if let gameCharacter = GameCharacter.all.first(where: { $0.id == id }) {
            return gameCharacter
        }
        throw SpriteError.noGameCharacterFound.rawValue
    }
}

