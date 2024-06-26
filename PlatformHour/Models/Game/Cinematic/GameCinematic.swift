//
//  GameCinematic.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 09/04/23.
//

import Foundation
import UtilityToolbox

struct GameCinematic: Codable {
    
    let name: String
    let category: Category
    let actions: [CinematicAction]
    var conversationCompletion: String?
    var specialCompletion: SpecialCompletion?
    
    enum Category: String, Codable {
        case onLevelStart
        case onObject
        case onPlayerCoordinate
        case onConversation
    }
    
    enum SpecialCompletion: String, Codable {
        case barrierAdding
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case category
        case actions
        case conversationCompletion
        case specialCompletion
    }
}

extension GameCinematic {
    
    /// Returns all the game cinematics.
    static var all: [GameCinematic]? {
        try? GameConfiguration.bundleManager.decodeJSON(GameConfiguration.jsonKey.cinematics)
    }
    
    static func get(_ name: String) -> GameCinematic? {
        let cinematic = GameCinematic.all?.first(where: { $0.name == name })
        return cinematic
    }
}
