//
//  GameObject.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import Foundation
import PlayfulKit
import Utility_Toolbox

struct GameObject: Codable {
    let name: String
    let image: String
    var logic: GameObjectLogic
    var animation: [GameObjectAnimation]
    var specialAnimation: SpecialAnimation?
    let sound: String?
    
    var coordinate: Coordinate = Coordinate.zero
    
    enum SpecialAnimation: String, Codable {
        case shadowPulse
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case image
        case logic
        case animation
        case specialAnimation
        case sound
    }
}

extension GameObject {
    
    // MARK: - Data
    
    /// Returns the player object of the game.
    static var player: GameObject? {
        
        return try? GameConfiguration.bundleManager.decodeJSON(GameConfiguration.jsonKey.playerObject)
    }
    
    /// Returns important objects of the game.
    static var obstacles: [GameObject]? {
        return try? GameConfiguration.bundleManager.decodeJSON(GameConfiguration.jsonKey.obstacleObjects)
    }
    
    /// Returns important objects of the game.
    static var importants: [GameObject]? {
        return try? GameConfiguration.bundleManager.decodeJSON(GameConfiguration.jsonKey.importantObjects)
    }
    
    /// Returns NPC objects of the game.
    static var npcs: [GameObject]? {
        return try? GameConfiguration.bundleManager.decodeJSON(GameConfiguration.jsonKey.npcObjects)
    }
    
    /// Returns enemy objects of the game.
    static var enemies: [GameObject]? {
        return try? GameConfiguration.bundleManager.decodeJSON(GameConfiguration.jsonKey.enemyObjects)
    }
    
    /// Returns collectible objects of the game.
    static var collectibles: [GameObject]? {
        return try? GameConfiguration.bundleManager.decodeJSON(GameConfiguration.jsonKey.collectibleObjects)
    }
    
    /// Returns trap objects of the game.
    static var traps: [GameObject]? {
        return try? GameConfiguration.bundleManager.decodeJSON(GameConfiguration.jsonKey.trapObjects)
    }
    
    /// Returns interactive objects of the game.
    static var interactives: [GameObject]? {
        return try? GameConfiguration.bundleManager.decodeJSON(GameConfiguration.jsonKey.interactiveObjects)
    }
    
    /// Returns effect objects of the game.
    static var effects: [GameObject]? {
        return try? GameConfiguration.bundleManager.decodeJSON(GameConfiguration.jsonKey.effectObjects)
    }
    
    /// Returns all objects of the game.
    static var all: [GameObject] {
        let objects = [importants, npcs, enemies, collectibles, traps, interactives, effects].compactMap { $0 }
        let joinedObjects = objects.joined().map { $0 }
        return joinedObjects
    }
    
    // MARK: - Gets
    
    /// Returns an important object by giving its name.
    static func getObstacle(_ name: String) -> GameObject? {
        let obstacle = GameObject.obstacles?.first(where: {
            $0.name == name
        })
        return obstacle
    }
    
    /// Returns an important object by giving its name.
    static func getImportant(_ name: String) -> GameObject? {
        let important = GameObject.importants?.first(where: {
            $0.name == name
        })
        return important
    }
    
    /// Returns a NPC object by giving his name.
    static func getNPC(_ name: String) -> GameObject? {
        let npc = GameObject.npcs?.first(where: {
            $0.name == name
        })
        return npc
    }
    
    /// Returns an enemy object by giving his name.
    static func getEnemy(_ name: String) -> GameObject? {
        let enemy = GameObject.enemies?.first(where: {
            $0.name == name
        })
        return enemy
    }
    
    /// Returns a collectible object by giving his name.
    static func getCollectible(_ name: String) -> GameObject? {
        let collectible = GameObject.collectibles?.first(where: {
            $0.name == name
        })
        return collectible
    }
    
    /// Returns a trap object by giving his name.
    static func getTrap(_ name: String) -> GameObject? {
        let trap = GameObject.traps?.first(where: {
            $0.name == name
        })
        return trap
    }
    
    /// Returns an interactive object by giving its name.
    static func getInteractive(_ name: String) -> GameObject? {
        let container = GameObject.interactives?.first(where: {
            $0.name == name
        })
        return container
    }
    
    /// Returns an effect object by giving its name.
    static func getEffect(_ name: String) -> GameObject? {
        let effect = GameObject.effects?.first(where: { $0.name == name })
        return effect
    }
    
    /// Returns an object by giving its name.
    static func get(_ name: String) -> GameObject? {
        let object = GameObject.all.first(where: { $0.name == name })
        return object
    }
    
    // MARK: - Utils
    
    /// Returns the animations of the object.
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
    
    /// Returns one animation from the object by giving his state ID.
    func animation(stateID: GameAnimation.StateID) -> ObjectAnimation? {
        animations.first { $0.identifier == stateID.rawValue }
    }
}
