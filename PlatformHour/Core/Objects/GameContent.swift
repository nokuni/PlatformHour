//
//  GameContent.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import SpriteKit
import PlayfulKit
import Utility_Toolbox

final public class GameContent {
    
    init(scene: GameScene,
         environment: GameEnvironment,
         animation: GameAnimation,
         logic: GameLogic) {
        self.scene = scene
        self.environment = environment
        self.animation = animation
        self.logic = logic
        createContent()
    }
    
    var scene: GameScene
    var environment: GameEnvironment
    var animation: GameAnimation
    var logic: GameLogic
    
    // Objects
    public func object(name: String? = nil,
                       physicsBodySizeTailoring: CGFloat = 0,
                       collision: Collision) -> PKObjectNode {
        
        let object = PKObjectNode()
        object.name = name
        object.size = GameConfiguration.worldConfiguration.tileSize
        
        object.applyPhysicsBody(
            size: object.size + physicsBodySizeTailoring,
            collision: collision
        )
        
        return object
    }
    public var projectileNode: PKObjectNode {
        guard let player = scene.player else { return PKObjectNode() }
        let currentRoll = player.currentRoll.rawValue
        
        let collision = Collision(category: .playerProjectile,
                                  collision: [.object, .structure, .enemy],
                                  contact: [.object, .structure])
        
        let attackNode = object(name: GameConfiguration.sceneConfigurationKey.playerProjectile,
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
    
    // MARK: - Main
    
    private func createContent() {
        createGround()
        //createTrees()
        //createStatue()
        //createPlatform()
        createObstacles()
        createGems()
        createTraps()
        createContainers()
        createExit()
        createNPCs()
        configurePlayer()
        createPlayer()
        createEnemies()
    }
    
    // MARK: - Player
    private func createPlayer() {
        if let player = scene.player {
            scene.addChildSafely(player.node)
        }
    }
    private func configurePlayer() {
        guard let level = scene.game?.level else { return }
        guard let dice = scene.player else { return }
        let collision = Collision(category: .player,
                                  collision: [.allClear],
                                  contact: [.enemyProjectile, .object, .npc, .enemy])
        
        dice.node = object(name: GameConfiguration.sceneConfigurationKey.player,
                           collision: collision)
        
        dice.node.logic = LogicBody(health: dice.logic.health, damage: dice.logic.damage, isDestructible: dice.logic.isDestructible, isIntangible: dice.logic.isIntangible)
        
        dice.node.zPosition = GameConfiguration.worldConfiguration.playerZPosition
        
        dice.node.physicsBody?.friction = 0
        dice.node.physicsBody?.allowsRotation = false
        dice.node.physicsBody?.affectedByGravity = false
        
        //addHealthBar(amount: dice.currentBarHealth, node: dice.node, widthTailoring: (GameConfiguration.worldConfiguration.tileSize.width / 16) * 4)
        
        guard let position = environment.map.tilePosition(from: level.playerCoordinate.coordinate) else {
            return
        }
        
        dice.node.coordinate = level.playerCoordinate.coordinate
        dice.node.position = position
        dice.node.texture = SKTexture(imageNamed: "dice\(dice.currentRoll.rawValue)Idle")
        dice.node.texture?.filteringMode = .nearest
    }
    
    // MARK: - Enemies
    private func createEnemies() {
        if let level = scene.game?.level {
            for enemy in level.enemies {
                createEnemy(enemy)
            }
        }
    }
    private func createEnemy(_ levelEnemy: LevelEnemy) {
        if let enemy = GameObject.getEnemy(levelEnemy.name) {
            let collision = Collision(category: .enemy,
                                      collision: [.allClear],
                                      contact: [.player, .playerProjectile])
            
            let runIdentifier = GameAnimation.StateID.run.rawValue
            let deathIdentifier = GameAnimation.StateID.death.rawValue
            
            guard let run = enemy.animation.first(where: { $0.identifier == runIdentifier }) else {
                return
            }
            
            guard let death = enemy.animation.first(where: { $0.identifier == deathIdentifier }) else {
                return
            }
            
            let runObjectAnimation = ObjectAnimation(identifier: run.identifier, frames: run.frames)
            let deathObjectAnimation = ObjectAnimation(identifier: death.identifier, frames: death.frames)
            
            let animations = [runObjectAnimation, deathObjectAnimation]
            
            let enemyNode = object(name: enemy.name,
                                   physicsBodySizeTailoring: -(CGSize.screen.height * 0.1),
                                   collision: collision)
            
            enemyNode.logic = LogicBody(health: enemy.logic.health,
                                        damage: enemy.logic.damage,
                                        isDestructible: enemy.logic.isDestructible,
                                        isIntangible: enemy.logic.isIntangible)
            
            enemyNode.animations = animations
            
            guard let position = environment.map.tilePosition(from: levelEnemy.coordinate.coordinate) else { return }
            
            enemyNode.coordinate = levelEnemy.coordinate.coordinate
            enemyNode.zPosition = GameConfiguration.worldConfiguration.playerZPosition
            enemyNode.position = position
            enemyNode.texture = SKTexture(imageNamed: enemy.image)
            enemyNode.texture?.filteringMode = .nearest
            
            enemyNode.physicsBody?.friction = 0
            enemyNode.physicsBody?.allowsRotation = false
            enemyNode.physicsBody?.affectedByGravity = false
            
            print("Enemy added")
            scene.addChildSafely(enemyNode)
            
            addEnemyItinerary(enemy: enemyNode, itinerary: levelEnemy.itinerary, frames: runObjectAnimation.frames)
        }
    }
    
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
    
    // MARK: - Ground
    private func createGround() {
        if let level = scene.game?.level {
            
            for structure in level.structures {
                //                let pattern = MapStructurePattern(map: environment.map,
                //                                                  matrix: structure.matrix.matrix,
                //                                                  coordinate: structure.coordinate.coordinate,
                //                                                  object: environment.structureObjectElement,
                //                                                  simple: StructurePatternConfiguration.GroundSimplePattern.cave)
                //                pattern.create()
                let mapStructure = MapStructure(topLeft: SKTexture(imageNamed: "caveGround00"),
                                                topRight: SKTexture(imageNamed: "caveGround04"),
                                                bottomLeft: SKTexture(imageNamed: "caveGround40"),
                                                bottomRight: SKTexture(imageNamed: "caveGround44"),
                                                left: SKTexture(imageNamed: "caveGround00"),
                                                right: SKTexture(imageNamed: "caveGround04"),
                                                top: SKTexture(imageNamed: "caveGround01"),
                                                bottom: SKTexture(imageNamed: "caveGround41"),
                                                middle: SKTexture(imageNamed: "caveGround33"))
                let pattern = TestPattern(map: environment.map,
                                          matrix: structure.matrix.matrix,
                                          coordinate: structure.coordinate.coordinate,
                                          object: environment.structureObjectElement,
                                          structure: mapStructure)
                pattern.create()
            }
        }
    }
    
    // MARK: - Obstacles
    
    private func createObstacles() {
        if let level = scene.game?.level {
            for obstacle in level.obstacles {
                let texture = SKTexture(imageNamed: obstacle.image)
                texture.filteringMode = .nearest
                environment.map.addObject(environment.structureObjectElement,
                                          texture: texture,
                                          size: environment.map.squareSize,
                                          logic: LogicBody(),
                                          animations: [],
                                          matrix: obstacle.matrix.matrix,
                                          startingCoordinate: obstacle.coordinate.coordinate)
            }
        }
    }
    private func createGems() {
        if let level = scene.game?.level {
            for gem in level.gems {
                if let gemItem = try? GameItem.get(gem.item) {
                    createItem(gemItem, at: gem.coordinate.coordinate)
                }
            }
        }
    }
    public func createExit() {
        guard let level = scene.game?.level else { return }
        let collision = Collision(category: .npc,
                                  collision: [.allClear],
                                  contact: [.player])
        
        let coordinate = level.exit.coordinate.coordinate
        guard let exitPosition = environment.map.tilePosition(from: coordinate) else { return }
        
        let exit = environment.objectElement(name: GameConfiguration.sceneConfigurationKey.exit,
                                             physicsBodySizeTailoring: -GameConfiguration.worldConfiguration.tileSize.width * 0.5,
                                             collision: collision)
        exit.texture = SKTexture(imageNamed: level.exit.sprite)
        exit.texture?.filteringMode = .nearest
        exit.position = exitPosition
        exit.physicsBody?.affectedByGravity = false
        scene.addChildSafely(exit)
    }
    public func createNPCs() {
        if let level = scene.game?.level {
            for npc in level.npcs {
                createNPC(npc)
            }
        }
    }
    public func createTraps() {
        if let level = scene.game?.level {
            for trap in level.traps {
                createTrap(trap)
            }
        }
    }
    
    private func createContainers() {
        if let level = scene.game?.level {
            for container in level.containers {
                let coordinate = container.coordinate.coordinate
                createContainer(container, at: coordinate)
            }
        }
    }
    
    private func createContainer(_ container: GameObjectContainer, at coordinate: Coordinate) {
        if let dataObject = GameObject.get(container.name) {
            
            let collision = Collision(category: .object,
                                      collision: [.player, .structure],
                                      contact: [.playerProjectile, .enemyProjectile])
            
            let logic = LogicBody(health: dataObject.logic.health,
                                  damage: dataObject.logic.damage,
                                  isDestructible: dataObject.logic.isDestructible,
                                  isIntangible: dataObject.logic.isIntangible)
            
            var drops: [Any] = []
            
            if let itemName = container.item,
               let item = try? GameItem.get(itemName) {
                drops.append(item)
            }
            
            guard let death = dataObject.animation.first(where: {
                $0.identifier == GameAnimation.StateID.death.rawValue
            }) else {
                return
            }
            
            let animations = [
                ObjectAnimation(identifier: death.identifier, frames: death.frames)
            ]
            
            let objectNode = PKObjectNode()
            objectNode.name = dataObject.name
            objectNode.size = GameConfiguration.worldConfiguration.tileSize
            objectNode.zPosition = 2
            objectNode.applyPhysicsBody(size: GameConfiguration.worldConfiguration.tileSize, collision: collision)
            objectNode.physicsBody?.isDynamic = false
            
            let texture = SKTexture(imageNamed: dataObject.image)
            texture.filteringMode = .nearest
            
            environment.map.addObject(objectNode,
                                      texture: texture,
                                      size: environment.map.squareSize,
                                      logic: logic,
                                      drops: drops,
                                      animations: animations,
                                      at: coordinate)
        }
    }
    private func createItem(_ item: GameItem, at coordinate: Coordinate) {
        
        guard let dataObject = GameObject.all?.first(where: { item.name.contains($0.name) }) else { return }
        //let dataObject = GameObject.get(item.name)
        
        let collision = Collision(category: .item,
                                  collision: [.structure],
                                  contact: [.player])
        
        let idleIdentifier = GameAnimation.StateID.idle.rawValue
        let deathIdentifier = GameAnimation.StateID.death.rawValue
        
        guard let idle = dataObject.animation.first(where: { $0.identifier == idleIdentifier }) else {
            return
        }
        guard let death = dataObject.animation.first(where: { $0.identifier == deathIdentifier }) else {
            return
        }
        
        let animations = [
            ObjectAnimation(identifier: idle.identifier, frames: idle.frames),
            ObjectAnimation(identifier: death.identifier, frames: death.frames)
        ]
        
        let itemNode = environment.objectElement(name: item.name,
                                                 physicsBodySizeTailoring: -(GameConfiguration.worldConfiguration.tileSize.width / 2),
                                                 collision: collision)
        itemNode.texture = SKTexture(imageNamed: item.sprite)
        itemNode.texture?.filteringMode = .nearest
        itemNode.animations = animations
        let position = environment.map.tilePosition(from: coordinate)
        itemNode.zPosition = GameConfiguration.worldConfiguration.objectZPosition
        itemNode.position = position ?? .zero
        itemNode.physicsBody?.isDynamic = false
        itemNode.physicsBody?.affectedByGravity = false
        scene.addChildSafely(itemNode)
        
        animation.idle(node: itemNode, filteringMode: .nearest, timeInterval: 0.1)
    }
    private func createNPC(_ npc: LevelNPC) {
        let collision = Collision(category: .npc,
                                  collision: [.allClear],
                                  contact: [.player])
        
        let coordinate = npc.coordinate.coordinate
        
        guard let npcPosition = environment.map.tilePosition(from: coordinate) else { return }
        
        let npcObject = environment.objectElement(name: "Feather",
                                                  physicsBodySizeTailoring: -GameConfiguration.worldConfiguration.tileSize.width * 0.5,
                                                  collision: collision)
        
        npcObject.texture = SKTexture(imageNamed: npc.sprite)
        npcObject.texture?.filteringMode = .nearest
        npcObject.position = npcPosition
        npcObject.physicsBody?.affectedByGravity = false
        scene.addChildSafely(npcObject)
    }
    public func createTrap(_ levelTrap: LevelTrap) {
        guard let trap = GameObject.getTrap(levelTrap.name) else { return }
        
        let deathIdentifier = GameAnimation.StateID.death.rawValue
        
        guard let death = trap.animation.first(where: { $0.identifier == deathIdentifier }) else { return }
        
        let deathObjectAnimation = ObjectAnimation(identifier: death.identifier, frames: death.frames)
        
        let animations = [deathObjectAnimation]
        
        let collision = Collision(category: .enemy,
                                  collision: [.allClear],
                                  contact: [.player, .playerProjectile])
        
        let trapNode = object(name: "\(levelTrap.name) \(levelTrap.id)",
                              physicsBodySizeTailoring: -(CGSize.screen.height * 0.1),
                              collision: collision)
        
        trapNode.logic = LogicBody(health: trap.logic.health,
                                   damage: trap.logic.damage,
                                   isDestructible: trap.logic.isDestructible,
                                   isIntangible: trap.logic.isIntangible)
        
        trapNode.animations = animations
        
        guard let position = environment.map.tilePosition(from: levelTrap.coordinate.coordinate) else {
            return
        }
        
        trapNode.coordinate = levelTrap.coordinate.coordinate
        trapNode.zPosition = GameConfiguration.worldConfiguration.playerZPosition
        trapNode.position = position
        trapNode.texture = SKTexture(imageNamed: trap.image)
        trapNode.texture?.filteringMode = .nearest
        
        trapNode.physicsBody?.friction = 0
        trapNode.physicsBody?.allowsRotation = false
        trapNode.physicsBody?.affectedByGravity = false
        
        scene.addChildSafely(trapNode)
        
        logic.dropTrap(trapObject: trapNode)
    }
    
    // Additions
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
    
    // States
    func pause() { /*container.isPaused = true*/ }
    func unpause() { /*container.isPaused = false*/ }
}

/*
 {
 "name": "Enemy Slime",
 "coordinate": "2913",
 "itinerary": 6
 }
 
 {
 "name": "Cube 6",
 "coordinate": "2946"
 }
 
 {
 "image": "caveGround00",
 "matrix": "0402",
 "coordinate": "2644"
 }
 */
