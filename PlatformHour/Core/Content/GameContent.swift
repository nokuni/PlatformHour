//
//  GameContent.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import SwiftUI
import SpriteKit
import PlayfulKit
import Utility_Toolbox

final public class GameContent {
    
    public init(scene: GameScene,
                environment: GameEnvironment,
                animation: GameAnimation,
                logic: GameLogic) {
        self.scene = scene
        self.environment = environment
        self.animation = animation
        self.logic = logic
        generate()
    }
    
    public var scene: GameScene
    public var environment: GameEnvironment
    public var animation: GameAnimation
    public var logic: GameLogic
    
    private func generate() {
        generateLevelStructures()
        generateLevelCollectibles()
        generateLevelTraps()
        generateLevelContainers()
        generateLevelExit()
        generateLevelNPCs()
        generateLevelEnemies()
        generateLevelPlayer()
    }
}

// MARK: - Level Generations

public extension GameContent {
    
    /// Generate the player on the current level.
    private func generateLevelPlayer() {
        configurePlayer()
        if let player = scene.player {
            scene.addChildSafely(player.node)
        }
    }
    
    /// Generate the enemies on the current level.
    private func generateLevelEnemies() {
        if let level = scene.game?.level {
            for enemy in level.objects(category: .enemy) {
                createLevelEnemy(enemy)
            }
        }
    }
    
    /// Generate the structures on the current level.
    private func generateLevelStructures() {
        guard let level = scene.game?.level else { return }
        
        for structure in level.structures {
            
            let construct = SpiralStructureConstruct(outline: structure.outline,
                                                     firstLayer: structure.firstLayer,
                                                     innerLayer: structure.innerLayer)
            
            let outlinePattern = construct.outlinePattern
            let firstLayerPattern = construct.firstLayerPattern
            let innerPatterns = construct.innerPatterns(structure: structure)
            
            var patterns = [outlinePattern, firstLayerPattern]
            patterns.append(contentsOf: innerPatterns)
            
            let safePatterns = patterns.compactMap { $0 }
            
            let mapStructure = SpiralStructurePattern.Structure(patterns: safePatterns)
            
            let pattern = SpiralStructurePattern(map: environment.map,
                                                 matrix: structure.matrix.matrix,
                                                 coordinate: structure.coordinate.coordinate,
                                                 object: environment.structureObjectElement,
                                                 structure: mapStructure)
            pattern.create()
        }
    }
    
    /// Generate the gems on the current level.
    private func generateLevelCollectibles() {
        if let level = scene.game?.level {
            for collectible in level.objects(category: .collectible) {
                createLevelCollectible(collectible)
            }
        }
    }
    
    /// Generate the level exit on the current level.
    func generateLevelExit() {
        guard let level = scene.game?.level else { return }
        guard let exit = level.exit else { return }
        guard let exitData = GameObject.getImportant(GameConfiguration.nodeKey.exit) else { return }
        
        let collision = Collision(category: .npc,
                                  collision: [.allClear],
                                  contact: [.player])
        
        let coordinate = exit.coordinate.coordinate
        
        guard let exitPosition = environment.map.tilePosition(from: coordinate) else { return }
        
        let exitNode = environment.objectElement(name: GameConfiguration.nodeKey.exit,
                                                 physicsBodySizeTailoring: -GameConfiguration.sceneConfiguration.tileSize.width * 0.5,
                                                 collision: collision)
        exitNode.coordinate = coordinate
        exitNode.texture = SKTexture(imageNamed: exitData.image)
        exitNode.texture?.filteringMode = .nearest
        exitNode.position = exitPosition
        exitNode.physicsBody?.affectedByGravity = false
        scene.addChildSafely(exitNode)
    }
    
    /// Generate the NPCs on the current level.
    func generateLevelNPCs() {
        if let level = scene.game?.level {
            for npc in level.objects(category: .npc) {
                createLevelNPC(npc)
            }
        }
    }
    
    /// Generate the traps on the current level.
    func generateLevelTraps() {
        if let level = scene.game?.level {
            for trap in level.objects(category: .trap) {
                createLevelTrap(trap)
            }
        }
    }
    
    /// Generate an containers on the current level.
    private func generateLevelContainers() {
        if let level = scene.game?.level {
            for container in level.objects(category: .container) {
                createLevelContainer(container)
            }
        }
    }
}

// MARK: - Level Creations

public extension GameContent {
    
    /// Create a level container.
    private func createLevelContainer(_ levelContainer: LevelObject) {
        if let containerData = GameObject.getContainer(levelContainer.name) {
            
            let collision = Collision(category: .object,
                                      collision: [.player, .structure],
                                      contact: [.playerProjectile, .enemyProjectile])
            
            let logic = LogicBody(health: containerData.logic.health,
                                  damage: containerData.logic.damage,
                                  isDestructible: containerData.logic.isDestructible,
                                  isIntangible: containerData.logic.isIntangible)
            
            let objectNode = PKObjectNode()
            objectNode.name = containerData.name
            objectNode.size = GameConfiguration.sceneConfiguration.tileSize
            objectNode.zPosition = 2
            objectNode.applyPhysicsBody(size: GameConfiguration.sceneConfiguration.tileSize, collision: collision)
            objectNode.physicsBody?.isDynamic = false
            
            let texture = SKTexture(imageNamed: containerData.image)
            texture.filteringMode = .nearest
            
            environment.map.addObject(objectNode,
                                      texture: texture,
                                      size: environment.map.squareSize,
                                      logic: logic,
                                      animations: containerData.animations,
                                      at: levelContainer.coordinate.coordinate)
        }
    }
    
    /// Create a level collectible.
    private func createLevelCollectible(_ levelCollectible: LevelObject) {
        
        if let collectibleData = GameObject.getCollectible(levelCollectible.name) {
            
            guard let position = environment.map.tilePosition(from: levelCollectible.coordinate.coordinate) else {
                return
            }
            
            let collision = Collision(category: .item,
                                      collision: [.structure],
                                      contact: [.player])
            
            let itemNode = environment.objectElement(name: collectibleData.name,
                                                     physicsBodySizeTailoring: -(GameConfiguration.sceneConfiguration.tileSize.width / 2),
                                                     collision: collision)
            
            itemNode.texture = SKTexture(imageNamed: collectibleData.image)
            itemNode.texture?.filteringMode = .nearest
            itemNode.animations = collectibleData.animations
            itemNode.zPosition = GameConfiguration.sceneConfiguration.objectZPosition
            itemNode.position = position
            itemNode.physicsBody?.isDynamic = false
            itemNode.physicsBody?.affectedByGravity = false
            scene.addChildSafely(itemNode)
            
            animation.idle(node: itemNode, filteringMode: .nearest, timeInterval: 0.1)
        }
    }
    
    /// Create a level NPC.
    func createLevelNPC(_ levelNPC: LevelObject) {
        guard let npcData = GameObject.getNPC(levelNPC.name) else { return }
        
        let collision = Collision(category: .npc,
                                  collision: [.allClear],
                                  contact: [.player])
        
        let coordinate = levelNPC.coordinate.coordinate
        
        guard let npcPosition = environment.map.tilePosition(from: coordinate) else { return }
        
        let npcObjectNode = environment.objectElement(name: levelNPC.name,
                                                      physicsBodySizeTailoring: -GameConfiguration.sceneConfiguration.tileSize.width * 0.5,
                                                      collision: collision)
        
        npcObjectNode.animations = npcData.animations
        npcObjectNode.coordinate = coordinate
        npcObjectNode.size = environment.map.squareSize * CGFloat(levelNPC.sizeGrowth)
        npcObjectNode.texture = SKTexture(imageNamed: npcData.image)
        npcObjectNode.texture?.filteringMode = .nearest
        npcObjectNode.position = npcPosition
        npcObjectNode.physicsBody?.affectedByGravity = false
        scene.addChildSafely(npcObjectNode)
        
        let animation = animation.animate(node: npcObjectNode, identifier: .idle, filteringMode: .nearest, timeInterval: 0.1)
        
        npcObjectNode.run(SKAction.repeatForever(animation))
    }
    
    /// Create a trap.
    func createLevelTrap(_ levelTrap: LevelObject) {
        guard let trapData = GameObject.getTrap(levelTrap.name) else { return }
        
        let collision = Collision(category: .enemy,
                                  collision: [.allClear],
                                  contact: [.player, .playerProjectile])
        
        let trapNode = object(name: "\(levelTrap.name) \(levelTrap.id)",
                              physicsBodySizeTailoring: -(CGSize.screen.height * 0.1),
                              collision: collision)
        
        trapNode.logic = LogicBody(health: trapData.logic.health,
                                   damage: trapData.logic.damage,
                                   isDestructible: trapData.logic.isDestructible,
                                   isIntangible: trapData.logic.isIntangible)
        
        trapNode.animations = trapData.animations
        
        guard let position = environment.map.tilePosition(from: levelTrap.coordinate.coordinate) else {
            return
        }
        
        trapNode.coordinate = levelTrap.coordinate.coordinate
        trapNode.zPosition = GameConfiguration.sceneConfiguration.playerZPosition
        trapNode.position = position
        trapNode.texture = SKTexture(imageNamed: trapData.image)
        trapNode.texture?.filteringMode = .nearest
        
        trapNode.physicsBody?.friction = 0
        trapNode.physicsBody?.allowsRotation = false
        trapNode.physicsBody?.affectedByGravity = false
        
        scene.addChildSafely(trapNode)
        
        logic.dropTrap(trapObject: trapNode)
    }
    
    /// Create an enemy.
    private func createLevelEnemy(_ levelEnemy: LevelObject) {
        if let enemyData = GameObject.getEnemy(levelEnemy.name) {
            let collision = Collision(category: .enemy,
                                      collision: [.allClear],
                                      contact: [.player, .playerProjectile])
            
            let enemyNode = object(name: enemyData.name,
                                   physicsBodySizeTailoring: -(CGSize.screen.height * 0.1),
                                   collision: collision)
            
            enemyNode.logic = LogicBody(health: enemyData.logic.health,
                                        damage: enemyData.logic.damage,
                                        isDestructible: enemyData.logic.isDestructible,
                                        isIntangible: enemyData.logic.isIntangible)
            
            enemyNode.animations = enemyData.animations
            
            guard let position = environment.map.tilePosition(from: levelEnemy.coordinate.coordinate) else { return }
            
            enemyNode.coordinate = levelEnemy.coordinate.coordinate
            enemyNode.zPosition = GameConfiguration.sceneConfiguration.playerZPosition
            enemyNode.position = position
            enemyNode.texture = SKTexture(imageNamed: enemyData.image)
            enemyNode.texture?.filteringMode = .nearest
            
            enemyNode.physicsBody?.friction = 0
            enemyNode.physicsBody?.allowsRotation = false
            enemyNode.physicsBody?.affectedByGravity = false
            
            print("Enemy added")
            scene.addChildSafely(enemyNode)
            
            if let runAnimation = enemyData.animation(stateID: .run),
               let itinerary = levelEnemy.itinerary {
                addEnemyItinerary(enemy: enemyNode, itinerary: itinerary, frames: runAnimation.frames)
            }
        }
    }
}

// MARK: - Objects

public extension GameContent {
    
    /// Returns a default setuped object.
    func object(name: String? = nil,
                physicsBodySizeTailoring: CGFloat = 0,
                collision: Collision) -> PKObjectNode {
        
        let object = PKObjectNode()
        object.name = name
        object.size = GameConfiguration.sceneConfiguration.tileSize
        
        object.applyPhysicsBody(
            size: object.size + physicsBodySizeTailoring,
            collision: collision
        )
        
        return object
    }
    
    /// Returns an object setuped to be a player projectile.
    var projectileNode: PKObjectNode {
        guard let player = scene.player else { return PKObjectNode() }
        let currentRoll = player.currentRoll.rawValue
        
        let collision = Collision(category: .playerProjectile,
                                  collision: [.object, .structure, .enemy],
                                  contact: [.object, .structure])
        
        let attackNode = object(name: GameConfiguration.nodeKey.playerProjectile,
                                physicsBodySizeTailoring: -(CGSize.screen.height * 0.1),
                                collision: collision)
        
        attackNode.logic.damage = currentRoll
        attackNode.texture = SKTexture(imageNamed: player.node.texture?.name ?? "")
        attackNode.texture?.filteringMode = .nearest
        attackNode.coordinate = player.node.coordinate
        attackNode.zPosition = 2
        attackNode.position = player.node.position
        attackNode.alpha = 0.5
        
        attackNode.physicsBody?.affectedByGravity = false
        attackNode.physicsBody?.restitution = -10
        attackNode.physicsBody?.friction = 0
        attackNode.physicsBody?.allowsRotation = false
        
        return attackNode
    }
}

// MARK: Configurations

public extension GameContent {
    
    /// Configure the player object.
    private func configurePlayer() {
        guard let level = scene.game?.level else { return }
        guard let player = scene.player else { return }
        guard let playerData = player.dataObject else { return }
        
        let collision = Collision(category: .player,
                                  collision: [.allClear],
                                  contact: [.enemyProjectile, .object, .npc, .enemy])
        
        player.node = object(name: playerData.name,
                             collision: collision)
        
        player.node.logic = LogicBody(health: playerData.logic.health,
                                      damage: playerData.logic.damage,
                                      isDestructible: playerData.logic.isDestructible,
                                      isIntangible: playerData.logic.isIntangible)
        
        player.node.zPosition = GameConfiguration.sceneConfiguration.playerZPosition
        player.node.physicsBody?.friction = 0
        player.node.physicsBody?.allowsRotation = false
        player.node.physicsBody?.affectedByGravity = false
        
        //addHealthBar(amount: dice.currentBarHealth, node: dice.node, widthTailoring: (GameConfiguration.worldConfiguration.tileSize.width / 16) * 4)
        
        guard let position = environment.map.tilePosition(from: level.playerCoordinate.coordinate) else {
            return
        }
        
        player.node.coordinate = level.playerCoordinate.coordinate
        player.node.position = position
        
        if let sprite = player.sprite {
            player.node.texture = SKTexture(imageNamed: sprite)
            player.node.texture?.filteringMode = .nearest
        }
    }
}

// MARK: - Creations

public extension GameContent {
    
    /// Creates and returns an object node.
    func createObject(_ object: GameObject, at coordinate: Coordinate) -> PKObjectNode {
        let collision = Collision(category: .object,
                                  collision: [.allClear],
                                  contact: [.allClear])
        
        guard let npcPosition = environment.map.tilePosition(from: coordinate) else {
            return PKObjectNode()
        }
        
        let objectNode = environment.objectElement(name: object.name,
                                                   physicsBodySizeTailoring: GameConfiguration.sceneConfiguration.objectCollisionSizeTailoring,
                                                   collision: collision)
        
        objectNode.coordinate = coordinate
        objectNode.animations = object.animations
        objectNode.texture = SKTexture(imageNamed: object.image)
        objectNode.texture?.filteringMode = .nearest
        objectNode.position = npcPosition
        objectNode.physicsBody?.affectedByGravity = false
        scene.addChildSafely(objectNode)
        
        return objectNode
    }
}

// MARK: - Miscellaneous

public extension GameContent {
    
    /// Pause the generated content.
    func pause() {
        /*container.isPaused = true*/
    }
    
    /// Unpause the generated content.
    func unpause() {
        /*container.isPaused = false*/
    }
}

// MARK: - Object Adds

public extension GameContent {
    
    /// Add a fixed intinerary movement to an enemy.
    private func addEnemyItinerary(enemy: PKObjectNode, itinerary: Int, frames: [String]) {
        let leftAnimation = SKAction.animate(with: frames, filteringMode: .nearest, timePerFrame: 0.2)
        
        let startPosition = enemy.position
        let endPosition = CGPoint(x: enemy.position.x + (environment.map.squareSize.width * CGFloat(itinerary)),
                                  y: enemy.position.y)
        
        let movement = SKAction.moveForthAndBack(startPoint: startPosition,
                                                 startAction: enemy.flipHorizontally,
                                                 endPoint: endPosition,
                                                 endAction: enemy.flipHorizontally,
                                                 startDuration: 3,
                                                 endDuration: 3)
        
        let repeatedAnimation = SKAction.repeatForever(leftAnimation)
        let repeatedMovement = SKAction.repeatForever(movement)
        
        let groupedAnimations = SKAction.group([repeatedAnimation, repeatedMovement])
        
        enemy.run(groupedAnimations)
    }
    
    /// Adds a health bar to the player.
    /*func addHealthBar(amount: CGFloat,
     node: PKObjectNode,
     widthTailoring: CGFloat = 0) {
     let tileSize = GameConfiguration.worldConfiguration.tileSize
     
     let bar = SKSpriteNode(imageNamed: "healthBar")
     bar.size = CGSize(width: tileSize.width - widthTailoring, height: tileSize.height)
     bar.texture?.filteringMode = .nearest
     
     let underBar = SKSpriteNode(imageNamed: "emptyBar")
     underBar.size = CGSize(width: tileSize.width - widthTailoring, height: tileSize.height)
     underBar.texture?.filteringMode = .nearest
     
     let configuration = PKProgressBarNode.ImageConfiguration(amount: amount,
     sprite: bar,
     underSprite: underBar)
     let progressBar = PKProgressBarNode(imageConfiguration: configuration)
     progressBar.name = "Health Bar"
     progressBar.position = CGPoint(x: 0, y: node.frame.size.height / 2)
     
     node.addChildSafely(progressBar)
     }*/
}
