//
//  GameItem.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 12/03/23.
//

import Foundation

public struct GameItem: Codable {
    public init(name: String,
                sprite: String) {
        self.name = name
        self.sprite = sprite
    }
    public var name: String
    public var sprite: String
    
    enum CodingKeys: String, CodingKey {
        case name, sprite
    }
}

extension GameItem {
    
    enum GameItemError: String, Error {
        case itemNotFound
    }
    
    static var all: [GameItem] {
        do {
            return try Bundle.main.decodeJSON("items.json")
        } catch {
            fatalError("Something wrong in the JSON.")
        }
    }
    
    static var allNames: [String] {
        GameItem.all.map { $0.name }
    }
    
    static func get(_ name: String) throws -> GameItem {
        if let object = GameItem.all.first(where: { $0.name == name }) {
            return object
        }
        throw GameItemError.itemNotFound.rawValue
    }
}
