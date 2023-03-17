//
//  GameObject.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import Foundation
import PlayfulKit

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
    
    static var all: [GameObject]? {
        return try? Bundle.main.decodeJSON(GameConfiguration.jsonConfigurationKey.objects)
    }
    
    static func get(_ name: String) -> GameObject? {
        let object = GameObject.all?.first(where: {
            $0.name == name
        })
        return object
    }
}
