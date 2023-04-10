//
//  GameObject.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import Foundation
import PlayfulKit

public struct GameObject: Codable {
    
    public init(name: String,
                image: String,
                logic: GameObjectLogic,
                animation: [GameObjectAnimation],
                sound: String,
                coordinate: Coordinate = Coordinate.zero) {
        self.name = name
        self.image = image
        self.logic = logic
        self.animation = animation
        self.sound = sound
        self.coordinate = coordinate
    }
    
    public let name: String
    public let image: String
    public var logic: GameObjectLogic
    public var animation: [GameObjectAnimation]
    public let sound: String?
    
    public var coordinate: Coordinate = Coordinate.zero
    
    enum CodingKeys: String, CodingKey {
        case name, image, logic, animation, sound
    }
}

public extension GameObject {
    
    // MARK: - Data
    
    static var player: GameObject? {
        return try? Bundle.main.decodeJSON(GameConfiguration.jsonKey.playerObject)
    }
    
    static var importants: [GameObject]? {
        return try? Bundle.main.decodeJSON(GameConfiguration.jsonKey.importantObjects)
    }
    
    static var npcs: [GameObject]? {
        return try? Bundle.main.decodeJSON(GameConfiguration.jsonKey.npcObjects)
    }
    
    static var enemies: [GameObject]? {
        return try? Bundle.main.decodeJSON(GameConfiguration.jsonKey.enemyObjects)
    }
    
    static var collectibles: [GameObject]? {
        return try? Bundle.main.decodeJSON(GameConfiguration.jsonKey.collectibleObjects)
    }
    
    static var traps: [GameObject]? {
        return try? Bundle.main.decodeJSON(GameConfiguration.jsonKey.trapObjects)
    }
    
    static var containers: [GameObject]? {
        return try? Bundle.main.decodeJSON(GameConfiguration.jsonKey.containerObjects)
    }
    
    // MARK: - Gets
    
    static func getImportant(_ name: String) -> GameObject? {
        let important = GameObject.importants?.first(where: {
            $0.name == name
        })
        return important
    }
    
    static func getNPC(_ name: String) -> GameObject? {
        let npc = GameObject.npcs?.first(where: {
            $0.name == name
        })
        return npc
    }
    
    static func getEnemy(_ name: String) -> GameObject? {
        let enemy = GameObject.enemies?.first(where: {
            $0.name == name
        })
        return enemy
    }
    
    static func getCollectible(_ name: String) -> GameObject? {
        let collectible = GameObject.collectibles?.first(where: {
            $0.name == name
        })
        return collectible
    }
    
    static func getTrap(_ name: String) -> GameObject? {
        let trap = GameObject.traps?.first(where: {
            $0.name == name
        })
        return trap
    }
    
    static func getContainer(_ name: String) -> GameObject? {
        let container = GameObject.containers?.first(where: {
            $0.name == name
        })
        return container
    }
    
    // MARK: - Values
    
    var animations: [ObjectAnimation] {
        
        let stateIDValues: [String] = GameAnimation.StateID.allCases.map { $0.rawValue }
        var animations: [ObjectAnimation] = []
        
        for gameObjectAnimation in self.animation where stateIDValues.contains(gameObjectAnimation.identifier) {
            let objectAnimation = ObjectAnimation(identifier: gameObjectAnimation.identifier,
                                                  frames: gameObjectAnimation.frames)
            animations.append(objectAnimation)
        }
        
        return animations
    }
    
    func animation(stateID: GameAnimation.StateID) -> ObjectAnimation? {
        animations.first { $0.identifier == stateID.rawValue }
    }
    
    // MARK: - Utils
    
    func decodedString(_ string: String?, cryptedCharacter: String, replacingvalue: String) -> String? {
        return string?.replacingOccurrences(of: cryptedCharacter, with: replacingvalue)
    }
    
    func decodedStrings(strings: [String]?, cryptedCharacter: String, replacingvalue: String) -> [String]? {
        let decodedFrames = strings?.compactMap {
            decodedString($0, cryptedCharacter: cryptedCharacter, replacingvalue: replacingvalue)
        }
        return decodedFrames
    }
}
