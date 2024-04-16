//
//  GameLevel.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import Foundation
import PlayfulKit
import UtilityToolbox

struct GameLevel: Codable {
    let id: Int
    let name: String
    let mapMatrix: String
    let playerCoordinate: String
    let musics: [String]
    let background: LevelBackground
    let objects: [LevelObject]
    let structures: [LevelStructure]
    @DecodableDefault.EmptyList var structureCavities: [String]
    var conversations: [LevelConversation]
    var cinematics: [LevelCinematic]
}

extension GameLevel {
    
    /// Returns all the game levels.
    static var all: [GameLevel]? {
        try? GameConfiguration.bundleManager.decodeJSON(GameConfiguration.jsonKey.levels)
    }
    
    /// Returns the level objects of a specific category.
    func objects(category: LevelObject.Category) -> [LevelObject] {
        objects.filter { $0.category == category }
    }
    
    /// Returns the level exit.
    var exit: LevelObject? {
        objects(category: .important).first { $0.name == GameConfiguration.nodeKey.exit }
    }
    
    static func get(_ id: Int) -> GameLevel? {
        let level = GameLevel.all?.first(where: {
            $0.id == id
        })
        return level
    }
}
