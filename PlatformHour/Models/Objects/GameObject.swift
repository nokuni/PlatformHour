//
//  GameObject.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import Foundation

struct GameObject: Codable {
    let category: Category
    
    enum Category: String, Codable {
        case numberBox
    }
}

extension GameObject {
    enum GameObjectError: String, Error {
        case objectNotFound
    }
    
    static let all: [GameObject] = try! Bundle.main.decode("objects.json")
    
    static func get(_ category: GameObject.Category) throws -> GameObject {
        if let object = GameObject.all.first(where: { $0.category == category }) {
            return object
        }
        throw GameObjectError.objectNotFound.rawValue
    }
}
