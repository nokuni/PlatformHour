//
//  GameCinematic.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 09/04/23.
//

import Foundation
import Utility_Toolbox

struct GameCinematic: Codable {
    
    let name: String
    let category: Category
    let actions: [CinematicAction]
    var conversationCompletion: String?
    
    enum Category: String, Codable {
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

extension GameCinematic {
    
    /// Returns all the game cinematics.
    static var all: [GameCinematic]? {
        try? Bundle.main.decodeJSON(GameConfiguration.jsonKey.cinematics)
    }
    
    static func get(_ name: String) -> GameCinematic? {
        let cinematic = GameCinematic.all?.first(where: { $0.name == name })
        return cinematic
    }
}
