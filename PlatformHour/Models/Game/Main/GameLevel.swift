//
//  GameLevel.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import Foundation
import PlayfulKit

public struct GameLevel: Codable {
    public init(id: Int,
                mapMatrix: String,
                playerCoordinate: String,
                musics: [String],
                background: LevelBackground,
                objects: [LevelObject],
                structures: [LevelStructure],
                dialogs: [LevelDialog],
                cinematics: [LevelCinematic]) {
        self.id = id
        self.mapMatrix = mapMatrix
        self.playerCoordinate = playerCoordinate
        self.musics = musics
        self.background = background
        self.objects = objects
        self.structures = structures
        self.dialogs = dialogs
        self.cinematics = cinematics
    }
    
    public let id: Int
    public let mapMatrix: String
    public let playerCoordinate: String
    public let musics: [String]
    public let background: LevelBackground
    public let objects: [LevelObject]
    public let structures: [LevelStructure]
    public var dialogs: [LevelDialog]
    public var cinematics: [LevelCinematic]
}

public extension GameLevel {
    
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
