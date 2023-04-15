//
//  GameLevel.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import Foundation
import PlayfulKit

struct GameLevel: Codable {
    init(id: Int,
         name: String,
         mapMatrix: String,
         playerCoordinate: String,
         musics: [String],
         background: LevelBackground,
         objects: [LevelObject],
         structures: [LevelStructure],
         conversations: [LevelConversation],
         cinematics: [LevelCinematic]) {
        self.id = id
        self.name = name
        self.mapMatrix = mapMatrix
        self.playerCoordinate = playerCoordinate
        self.musics = musics
        self.background = background
        self.objects = objects
        self.structures = structures
        self.conversations = conversations
        self.cinematics = cinematics
    }
    
    let id: Int
    let name: String
    let mapMatrix: String
    let playerCoordinate: String
    let musics: [String]
    let background: LevelBackground
    let objects: [LevelObject]
    let structures: [LevelStructure]
    var conversations: [LevelConversation]
    var cinematics: [LevelCinematic]
}

extension GameLevel {
    
    /// Returns all the game levels.
    static var all: [GameLevel]? {
        try? Bundle.main.decodeJSON(GameConfiguration.jsonKey.levels)
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
