//
//  GameCinematic.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 09/04/23.
//

import Foundation
import Utility_Toolbox

public struct GameCinematic: Codable {
    public init(name: String,
                category: GameCinematic.Category,
                actions: [CinematicAction],
                conversationCompletion: String? = nil) {
        self.name = name
        self.category = category
        self.actions = actions
        self.conversationCompletion = conversationCompletion
    }
    
    public let name: String
    public let category: Category
    public let actions: [CinematicAction]
    public var conversationCompletion: String?
    
    public enum Category: String, Codable {
        case onLevelStart
        case onNodeAlteration
        case onPlayerCoordinate
        case onConversation
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case category
        case actions
        case conversationCompletion
    }
}

public extension GameCinematic {
    
    /// Returns all the game cinematics.
    static var all: [GameCinematic]? {
        try? Bundle.main.decodeJSON(GameConfiguration.jsonKey.cinematics)
    }
    
    static func get(_ name: String) -> GameCinematic? {
        let cinematic = GameCinematic.all?.first(where: { $0.name == name })
        return cinematic
    }
}
