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

final class GameContent {
    
    init(scene: GameScene,
         environment: GameEnvironment,
         animation: GameAnimation,
         logic: GameLogic) {
        self.scene = scene
        self.environment = environment
        self.animation = animation
        self.logic = logic
        generate()
    }
    
    var scene: GameScene
    var environment: GameEnvironment
    var animation: GameAnimation
    var logic: GameLogic
    
    private func generate() {
        generateLevelStructures()
        digStructureCavities()
        generateLevelCollectibles()
        generateLevelTraps()
        generateLevelObstacles()
        generateLevelInteractives()
        generateLevelImportants()
        generateLevelNPCs()
        generateLevelEnemies()
        generateLevelPlayer()
    }
}

// MARK: - Level Generations

private extension GameContent {
    
    /// Generate the player on the current level.
    private func generateLevelPlayer() {
        configurePlayer()
        guard let player = scene.player else { return }
        scene.addChildSafely(player.node)
        if player.hasBarrier(scene: scene) { addPlayerBarrier() }
    }
    
    /// Generate the enemies on the current level.
    private func generateLevelEnemies() {
        guard let level = scene.game?.level else { return }
        for enemy in level.objects(category: .enemy) {
            createLevelEnemy(enemy)
        }
    }
    
    /// Generate the structures on the current level.
    private func generateLevelStructures() {
        guard let level = scene.game?.level else { return }
        for structure in level.structures {
            createLevelStructure(structure: structure)
        }
    }
    
    /// Generate the structures on the current level.
    private func generateLevelObstacles() {
        guard let level = scene.game?.level else { return }
        for obstacle in level.objects(category: .obstacle) {
            createLevelObstacle(obstacle)
        }
    }
    
    /// Generate the gems on the current level.
    private func generateLevelCollectibles() {
        guard let level = scene.game?.level else { return }
        for collectible in level.objects(category: .collectible) {
            createLevelCollectible(collectible)
        }
    }
    
    /// Generate the level important objects on the current level.
    private func generateLevelImportants() {
        guard let level = scene.game?.level else { return }
        for important in level.objects(category: .important) {
            createLevelImportant(important)
        }
    }
    
    /// Generate the NPCs on the current level.
    private func generateLevelNPCs() {
        guard let level = scene.game?.level else { return }
        for npc in level.objects(category: .npc) {
            createLevelNPC(npc)
        }
    }
    
    /// Generate the traps on the current level.
    private func generateLevelTraps() {
        guard let level = scene.game?.level else { return }
        for trap in level.objects(category: .trap) {
            createLevelTrap(trap)
        }
    }
    
    /// Generate the interactives objects on the current level.
    private func generateLevelInteractives() {
        guard let level = scene.game?.level else { return }
        for interactive in level.objects(category: .interactive) {
            createLevelInteractive(interactive)
        }
    }
}

// MARK: - Level Creations

extension GameContent {
    
    /// Create a level interactive.
    func createLevelInteractive(_ levelInteractive: LevelObject) {
        guard let interactiveObject = GameObject.getInteractive(levelInteractive.name) else { return }
        
        let collision = Collision(category: .object,
                                  collision: [.player],
                                  contact: [.npc])
        
        let nodeName = "\(levelInteractive.name) \(levelInteractive.id)"
        let collisionTailoring = levelInteractive.hasCollisionTailoring ? -GameConfiguration.sceneConfiguration.tileSize.width * 0.5 : 0
        
        let interactiveObjectNode = environment.objectElement(name: nodeName,
                                                              physicsBodySizeTailoring: collisionTailoring,
                                                              collision: collision)
        
        createLevelObject(node: interactiveObjectNode,
                          zPosition: GameConfiguration.sceneConfiguration.overObjectZPosition,
                          levelObject: levelInteractive,
                          gameObject: interactiveObject)
        
        levelObjectAnimation(node: interactiveObjectNode, identifier: .idle, isRepeatingForever: true)
    }
    
    /// Create a level collectible.
    private func createLevelCollectible(_ levelCollectible: LevelObject) {
        guard let collectibleObject = GameObject.getCollectible(levelCollectible.name) else { return }
        
        let collision = Collision(category: .item,
                                  collision: [.structure],
                                  contact: [.player])
        
        let collisionTailoring = levelCollectible.hasCollisionTailoring ? -(GameConfiguration.sceneConfiguration.tileSize.width / 2) : 0
        
        let collectibleNode = environment.objectElement(name: collectibleObject.name,
                                                        physicsBodySizeTailoring: collisionTailoring,
                                                        collision: collision)
        
        createLevelObject(node: collectibleNode,
                          zPosition: levelCollectible.sizeGrowth == 1 ?
                          GameConfiguration.sceneConfiguration.objectZPosition :
                          GameConfiguration.sceneConfiguration.betweenBackAndSceneZPosition,
                          levelObject: levelCollectible,
                          gameObject: collectibleObject)
        
        animation.idle(node: collectibleNode, filteringMode: .nearest, timeInterval: 0.1)
    }
    
    /// Create a level NPC.
    private func createLevelNPC(_ levelNPC: LevelObject) {
        guard let npcObject = GameObject.getNPC(levelNPC.name) else { return }
        
        let collision = Collision(category: .npc,
                                  collision: [.allClear],
                                  contact: [.player, .object])
        
        let collisionTailoring = levelNPC.hasCollisionTailoring ? -GameConfiguration.sceneConfiguration.tileSize.width * 0.5 : 0
        
        let npcObjectNode = environment.objectElement(name: levelNPC.name,
                                                      physicsBodySizeTailoring: collisionTailoring,
                                                      collision: collision)
        
        createLevelObject(node: npcObjectNode,
                          zPosition: levelNPC.sizeGrowth == 1 ?
                          GameConfiguration.sceneConfiguration.objectZPosition :
                          GameConfiguration.sceneConfiguration.betweenBackAndSceneZPosition,
                          levelObject: levelNPC,
                          gameObject: npcObject)
        
        levelObjectAnimation(node: npcObjectNode, identifier: .idle, isRepeatingForever: true)
    }
    
    /// Create a trap.
    func createLevelTrap(_ levelTrap: LevelObject) {
        guard let trapData = GameObject.getTrap(levelTrap.name) else { return }
        
        let collision = Collision(category: .enemy,
                                  collision: [.allClear],
                                  contact: [.player, .playerProjectile])
        
        let nodeName = "\(levelTrap.name) \(levelTrap.id)"
        let collisionTailoring = levelTrap.hasCollisionTailoring ? -GameConfiguration.sceneConfiguration.tileSize.width * 0.5 : 0
        
        let trapNode = object(name: nodeName,
                              physicsBodySizeTailoring: collisionTailoring,
                              collision: collision)
        
        trapNode.size = trapNode.size * levelTrap.sizeGrowth
        
        trapNode.logic = LogicBody(health: trapData.logic.health,
                                   damage: trapData.logic.damage,
                                   isDestructible: trapData.logic.isDestructible,
                                   isIntangible: trapData.logic.isIntangible)
        
        trapNode.animations = trapData.animations
        
        guard let position = environment.map.tilePosition(from: levelTrap.coordinate.coordinate) else {
            return
        }
        
        trapNode.coordinate = levelTrap.coordinate.coordinate
        trapNode.zPosition = GameConfiguration.sceneConfiguration.overPlayerZPosition
        trapNode.position = position
        trapNode.texture = SKTexture(imageNamed: trapData.image)
        trapNode.texture?.filteringMode = .nearest
        
        trapNode.physicsBody?.friction = 0
        trapNode.physicsBody?.allowsRotation = false
        trapNode.physicsBody?.affectedByGravity = false
        
        scene.addChildSafely(trapNode)
        
        if levelTrap.isRespawning {
            logic.dropTrap(trapObject: trapNode)
        }
    }
    
    private func createLevelImportant(_ levelImportant: LevelObject) {
        guard let importantObject = GameObject.getImportant(levelImportant.name) else { return }
        
        let collision = Collision(category: .npc,
                                  collision: [.allClear],
                                  contact: [.player])
        
        let nodeName = "\(levelImportant.name) \(levelImportant.id)"
        let collisionTailoring = levelImportant.hasCollisionTailoring ? -GameConfiguration.sceneConfiguration.tileSize.width * 0.5 : 0
        
        let importantObjectNode = environment.objectElement(name: nodeName,
                                                            physicsBodySizeTailoring: collisionTailoring,
                                                            collision: collision)
        
        createLevelObject(node: importantObjectNode,
                          zPosition: levelImportant.sizeGrowth == 1 ?
                          GameConfiguration.sceneConfiguration.objectZPosition :
                          GameConfiguration.sceneConfiguration.betweenBackAndSceneZPosition,
                          levelObject: levelImportant,
                          gameObject: importantObject)
        
        levelObjectAnimation(node: importantObjectNode, identifier: .idle, isRepeatingForever: true)
    }
    
    /// Create an enemy.
    private func createLevelEnemy(_ levelEnemy: LevelObject) {
        if let enemyData = GameObject.getEnemy(levelEnemy.name) {
            let collision = Collision(category: .enemy,
                                      collision: [.allClear],
                                      contact: [.player, .playerProjectile])
            
            let collisionTailoring = levelEnemy.hasCollisionTailoring ? -(CGSize.screen.height * 0.1) : 0
            
            let enemyNode = object(name: enemyData.name,
                                   physicsBodySizeTailoring: collisionTailoring,
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
            
            scene.addChildSafely(enemyNode)
            
            if let runAnimation = enemyData.animation(stateID: .run),
               let itinerary = levelEnemy.itinerary {
                addEnemyItinerary(enemy: enemyNode, itinerary: itinerary, frames: runAnimation.frames)
            }
        }
    }
    
    /// Create a level structure.
    private func createLevelStructure(structure: LevelStructure) {
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
    
    /// Create a level obstacle.
    private func createLevelObstacle(_ levelObstacle: LevelObject) {
        guard let obstacleObject = GameObject.getObstacle(levelObstacle.name) else { return }
        
        let collision = Collision(category: .structure,
                                  collision: [.player, .object],
                                  contact: [.player, .object])
        
        let collisionTailoring = levelObstacle.hasCollisionTailoring ? -GameConfiguration.sceneConfiguration.tileSize.width * 0.5 : 0
        
        let obstacleObjectNode = environment.objectElement(name: levelObstacle.name,
                                                           physicsBodySizeTailoring: collisionTailoring,
                                                           collision: collision)
        
        createLevelObject(node: obstacleObjectNode,
                          zPosition: levelObstacle.sizeGrowth == 1 ?
                          GameConfiguration.sceneConfiguration.objectZPosition :
                          GameConfiguration.sceneConfiguration.betweenBackAndSceneZPosition,
                          levelObject: levelObstacle,
                          gameObject: obstacleObject)
        
        //levelObjectAnimation(node: obstacleObjectNode, identifier: .idle, isRepeatingForever: true)
    }
    
    /// Create level object
    private func createLevelObject(node: PKObjectNode,
                                   zPosition: CGFloat,
                                   levelObject: LevelObject,
                                   gameObject: GameObject) {
        let coordinate = levelObject.coordinate.coordinate
        
        guard let position = environment.map.tilePosition(from: coordinate) else { return }
        
        node.logic = LogicBody(health: gameObject.logic.health,
                               damage: gameObject.logic.damage,
                               isDestructible: gameObject.logic.isDestructible,
                               isIntangible: gameObject.logic.isIntangible)
        
        node.animations = gameObject.animations
        node.coordinate = coordinate
        node.size = environment.map.squareSize * levelObject.sizeGrowth
        node.texture = SKTexture(imageNamed: gameObject.image)
        node.texture?.filteringMode = .nearest
        
        node.zPosition = zPosition
        
        node.position = position
        node.physicsBody?.affectedByGravity = false
        scene.addChildSafely(node)
        
        if let specialAnimation = gameObject.specialAnimation {
            switch specialAnimation {
            case .shadowPulse:
                animation.addShadowPulseEffect(scene: scene, node: node, duration: 1)
            }
        }
    }
}

// MARK: - Objects

extension GameContent {
    
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

extension GameContent {
    
    /// Configure the player object.
    private func configurePlayer() {
        guard let game = scene.game else { return }
        guard let level = game.level else { return }
        guard let player = scene.player else { return }
        guard let playerObject = player.object else { return }
        
        let collision = Collision(category: .player,
                                  collision: [.allClear],
                                  contact: [.enemyProjectile, .object, .npc, .enemy])
        
        player.refillTotalEnergy(game: game)
        
        player.node = object(name: playerObject.name,
                             collision: collision)
        
        player.node.logic = LogicBody(health: playerObject.logic.health,
                                      damage: playerObject.logic.damage,
                                      isDestructible: playerObject.logic.isDestructible,
                                      isIntangible: playerObject.logic.isIntangible)
        
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
    
    private func levelObjectAnimation(node: PKObjectNode,
                                      identifier: GameAnimation.StateID,
                                      timeInterval: TimeInterval = 0.1,
                                      repeatCount: Int = 1,
                                      isRepeatingForever: Bool = false) {
        let animation = animation.animate(node: node,
                                          identifier: identifier,
                                          filteringMode: .nearest,
                                          timeInterval: timeInterval)
        
        guard !node.animations.isEmpty else { return }
        
        SKAction.repeating(action: animation, node: node, count: repeatCount, isRepeatingForever: isRepeatingForever)
    }
    
    private func digStructureCavities() {
        guard let cavities = scene.game?.level?.structureCavities else { return }
        let coordinates = cavities.map { $0.coordinate }
        let objects = environment.map.objects.filter {
            coordinates.contains($0.coordinate)
        }
        objects.forEach { $0.removeFromParent() }
    }
}

// MARK: - Creations

extension GameContent {
    
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
    
    /// Creates and returns an object node.
    func createObject(_ object: GameObject, node: PKObjectNode) -> PKObjectNode {
        let collision = Collision(category: .object,
                                  collision: [.allClear],
                                  contact: [.allClear])
        
        let objectNode = environment.objectElement(name: object.name,
                                                   physicsBodySizeTailoring: GameConfiguration.sceneConfiguration.objectCollisionSizeTailoring,
                                                   collision: collision)
        
        objectNode.animations = object.animations
        objectNode.texture = SKTexture(imageNamed: object.image)
        objectNode.texture?.filteringMode = .nearest
        objectNode.physicsBody?.affectedByGravity = false
        node.addChildSafely(objectNode)
        
        return objectNode
    }
}

// MARK: - Miscellaneous

extension GameContent {
    
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

extension GameContent {
    
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
    
    /// Add energy barrier to player.
    func addPlayerBarrier() {
        guard let player = scene.player else { return }
        let barrierNode = SKSpriteNode(imageNamed: "barrierIdle")
        barrierNode.name = "Barrier"
        barrierNode.size = player.node.size
        barrierNode.texture?.filteringMode = .nearest
        barrierNode.colorBlendFactor = 1
        barrierNode.color = UIColor(Color.spiritBlue)
        player.node.addChildSafely(barrierNode)
    }
}
