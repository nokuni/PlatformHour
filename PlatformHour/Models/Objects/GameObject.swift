//
//  GameObject.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import Foundation
import PlayfulKit

struct GameObjectLogic: Codable {
    var health: Int
    var damage: Int
    var isDestructible: Bool
    var isIntangible: Bool
    
    enum CodingKeys: String, CodingKey {
        case health, damage, isDestructible, isIntangible
    }
}

struct GameObjectAnimation: Codable {
    var identifier: String
    var frames: [String]
}


struct GameObject: Codable {
    let name: String
    let image: String
    var logic: GameObjectLogic
    var animation: [GameObjectAnimation]
    var coordinate: Coordinate = Coordinate.zero
    
    enum CodingKeys: String, CodingKey {
        case name, image, logic, animation
    }
}

extension GameObject {
    
    enum GameObjectError: String, Error {
        case objectNotFound
    }
    
    static var all: [GameObject] {
        do {
            return try Bundle.main.decodeJSON("objects.json")
        } catch {
            fatalError("Something wrong in the JSON.")
        }
    }
    
    static func get(_ name: String) throws -> GameObject {
        if let object = GameObject.all.first(where: { $0.name == name }) {
            return object
        }
        throw GameObjectError.objectNotFound.rawValue
    }
}
