//
//  GameCharacter.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 07/04/23.
//

import Foundation

struct GameCharacter: Codable {
    
    init(name: String, fullArt: String) {
        self.name = name
        self.fullArt = fullArt
    }
    
    let name: String
    let fullArt: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case fullArt
    }
}

extension GameCharacter {
    
    /// Returns all the game characters of the game.
    static var all: [GameCharacter]? {
        try? Bundle.main.decodeJSON(GameConfiguration.jsonKey.characters)
    }
    
    static func get(_ name: String) -> GameCharacter? {
        let character = GameCharacter.all?.first(where: { $0.name == name })
        return character
    }
}
