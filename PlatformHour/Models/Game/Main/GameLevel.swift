//
//  GameLevel.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import Foundation
import PlayfulKit

struct GameLevel: Codable {
    let id: Int
    let mapMatrix: String
    let playerCoordinate: String
    let musics: [String]
    let background: LevelBackground
    let objects: [LevelObject]
    let structures: [LevelStructure]
    var dialogs: [LevelDialog]
}

extension GameLevel {
    
    static var all: [GameLevel]? {
        try? Bundle.main.decodeJSON(GameConfiguration.jsonKey.levels)
    }
    
    func objects(category: LevelObject.Category) -> [LevelObject] {
        objects.filter { $0.category == category }
    }
    
    var exit: LevelObject? {
        objects(category: .important).first { $0.name == "Exit" }
    }
    
    static func get(_ id: Int) -> GameLevel? {
        let level = GameLevel.all?.first(where: {
            $0.id == id
        })
        return level
    }
}
