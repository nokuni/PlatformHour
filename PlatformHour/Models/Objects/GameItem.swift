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
    
    static var all: [GameItem]? {
        return try? Bundle.main.decodeJSON(GameApp.jsonConfigurationKey.items)
    }
    
    static var allNames: [String]? {
        GameItem.all?.map { $0.name }
    }
    
    static func get(_ name: String) throws -> GameItem? {
        let object = GameItem.all?.first(where: { $0.name == name })
        return object
    }
}
