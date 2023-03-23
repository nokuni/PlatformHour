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
         environment: GameEnvironment) {
        self.scene = scene
        self.environment = environment
        createContent()
    }
    
    var scene: GameScene
    var environment: GameEnvironment
    
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
        createTrees()
        //createStatue()
        createContainers()
        createExit()
        configurePlayer()
        createPlayer()
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
                                  contact: [.enemyProjectile, .object, .npc])
        
        dice.node = object(name: GameConfiguration.sceneConfigurationKey.player,
                           collision: collision)
        
        dice.node.logic = LogicBody(health: dice.logic.health, damage: dice.logic.damage, isDestructible: dice.logic.isDestructible, isIntangible: dice.logic.isIntangible)
        
        dice.node.zPosition = GameConfiguration.worldConfiguration.playerZPosition
        
        dice.node.physicsBody?.friction = 0
        dice.node.physicsBody?.allowsRotation = false
        dice.node.physicsBody?.affectedByGravity = false
        
        addHealthBar(on: dice.node)
        
        guard let position = environment.map.tilePosition(from: level.playerCoordinate.coordinate) else {
            return
        }
        
        dice.node.coordinate = level.playerCoordinate.coordinate
        dice.node.position = position
        dice.node.texture = SKTexture(imageNamed: "dice\(dice.currentRoll.rawValue)Idle")
        dice.node.texture?.filteringMode = .nearest
    }
    
    // MARK: - Ground
    private func createGround() {
        let coordinate = Coordinate(x: 17, y: 0)
        
        if let ground = scene.game?.world?.ground {
            let structure: MapStructure = MapStructure(topLeft: ground.topLeft,
                                                       topRight: ground.topRight,
                                                       bottomLeft: ground.bottomLeft,
                                                       bottomRight: ground.bottomRight,
                                                       left: ground.left,
                                                       right: ground.right,
                                                       top: ground.top,
                                                       bottom: ground.bottom,
                                                       middle: ground.middle)
            environment.map.addObject(environment.structureObjectElement,
                                      structure: structure,
                                      filteringMode: .nearest,
                                      logic: LogicBody(),
                                      animations: [],
                                      startingCoordinate: coordinate,
                                      matrix: Matrix(row: 9, column: environment.mapMatrix.column))
        }
    }
    
    // MARK: - Objects
    /*private func createStatue() {
        
        guard let statue = scene.game?.level?.statue else { return }
        
        let collision = Collision(category: .npc,
                                  collision: [.allClear],
                                  contact: [.player])
        
        let pillarCoordinate = Coordinate(x: statue.coordinates[2].coordinate.x,
                                          y: statue.coordinates[0].coordinate.y - 1)
        
        environment.map.addObject(environment.backgroundObjectElement(name: GameConfiguration.sceneConfigurationKey.pillar, physicsBodySizeTailoring: -(CGSize.screen.height * 0.1), collision: collision),
                                  image: "springStatuePillar",
                                  filteringMode: .nearest,
                                  logic: LogicBody(isIntangible: true),
                                  animations: [],
                                  at: pillarCoordinate)
        
        environment.map.addObject(environment.backgroundObjectElement(name: GameConfiguration.sceneConfigurationKey.statue, collision: collision),
                                  image: "springStatueTopLeft",
                                  filteringMode: .nearest,
                                  logic: LogicBody(isIntangible: true),
                                  animations: [],
                                  at: statue.coordinates[0].coordinate)
        
        environment.map.addObject(environment.backgroundObjectElement(name: GameConfiguration.sceneConfigurationKey.statue, collision: collision),
                                  image: "springStatueTopRight",
                                  filteringMode: .nearest,
                                  logic: LogicBody(isIntangible: true),
                                  animations: [],
                                  at: statue.coordinates[1].coordinate)
        
        environment.map.addObject(environment.backgroundObjectElement(name: GameConfiguration.sceneConfigurationKey.statue, collision: collision),
                                  image: "springStatueBottomLeft",
                                  filteringMode: .nearest,
                                  logic: LogicBody(isIntangible: true),
                                  animations: [],
                                  at: statue.coordinates[2].coordinate)
        
        environment.map.addObject(environment.backgroundObjectElement(name: GameConfiguration.sceneConfigurationKey.statue, collision: collision),
                                  image: "springStatueBottomRight",
                                  filteringMode: .nearest,
                                  logic: LogicBody(isIntangible: true),
                                  animations: [],
                                  at: statue.coordinates[3].coordinate)
    }*/
    private func createTrees() {
        let collision = Collision(category: .allClear,
                                  collision: [.allClear],
                                  contact: [.allClear])
        
        var startingCoordinate = Coordinate(x: 16, y: 0)
        for _ in 0..<6 {
            environment.map.addObject(environment.backgroundObjectElement(collision: collision),
                                      image: "springTreeTopLeft",
                                      filteringMode: .nearest,
                                      logic: LogicBody(isIntangible: true),
                                      animations: [],
                                      at: .init(x: startingCoordinate.x - 1, y: startingCoordinate.y + 1))
            
            environment.map.addObject(environment.backgroundObjectElement(collision: collision),
                                      image: "springTreeTopRight",
                                      filteringMode: .nearest,
                                      logic: LogicBody(isIntangible: true),
                                      animations: [],
                                      at: .init(x: startingCoordinate.x - 1, y: startingCoordinate.y + 2))
            
            environment.map.addObject(environment.backgroundObjectElement(collision: collision),
                                      image: "springTreeBottomRight",
                                      filteringMode: .nearest,
                                      logic: LogicBody(isIntangible: true),
                                      animations: [],
                                      at: .init(x: startingCoordinate.x, y: startingCoordinate.y + 1))
            
            environment.map.addObject(environment.backgroundObjectElement(collision: collision),
                                      image: "springTreeBottomLeft",
                                      filteringMode: .nearest,
                                      logic: LogicBody(isIntangible: true),
                                      animations: [],
                                      at: .init(x: startingCoordinate.x, y: startingCoordinate.y + 2))
            
            environment.map.addObject(environment.backgroundObjectElement(collision: collision),
                                      image: "springTreeTopLeft",
                                      filteringMode: .nearest,
                                      logic: LogicBody(isIntangible: true),
                                      animations: [],
                                      at: .init(x: startingCoordinate.x, y: startingCoordinate.y))
            
            environment.map.addObject(environment.backgroundObjectElement(collision: collision),
                                      image: "springTreeTopRight",
                                      filteringMode: .nearest,
                                      logic: LogicBody(isIntangible: true),
                                      animations: [],
                                      at: .init(x: startingCoordinate.x, y: startingCoordinate.y + 3))
            
            environment.map.addObject(environment.backgroundObjectElement(collision: collision),
                                      image: "springTreeTopLeft",
                                      filteringMode: .nearest,
                                      logic: LogicBody(isIntangible: true),
                                      animations: [],
                                      at: .init(x: startingCoordinate.x, y: startingCoordinate.y + 6))
            
            environment.map.addObject(environment.backgroundObjectElement(collision: collision),
                                      image: "springTreeTopRight",
                                      filteringMode: .nearest,
                                      logic: LogicBody(isIntangible: true),
                                      animations: [],
                                      at: .init(x: startingCoordinate.x, y: startingCoordinate.y + 7))
            
            startingCoordinate.y += 10
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
            objectNode.zPosition = GameConfiguration.worldConfiguration.objectZPosition
            objectNode.applyPhysicsBody(size: GameConfiguration.worldConfiguration.tileSize, collision: collision)
            objectNode.physicsBody?.isDynamic = false
            
            environment.map.addObject(objectNode,
                                      image: dataObject.image,
                                      filteringMode: .nearest,
                                      logic: logic,
                                      drops: drops,
                                      animations: animations,
                                      at: coordinate)
        }
    }
    
    public func dropItem(_ item: GameItem, at coordinate: Coordinate) {
        
        let dataObject = GameObject.get(item.name)
        
        let collision = Collision(category: .item,
                                  collision: [.structure],
                                  contact: [.player])
        
        guard let idle = dataObject?.animation.first(where: {
            $0.identifier == GameAnimation.StateID.idle.rawValue
        }) else {
            return
        }
        
        let animations = [
            ObjectAnimation(identifier: idle.identifier, frames: idle.frames)
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
        scene.addChildSafely(itemNode)
        
        scene.core?.animation.idle(node: itemNode, filteringMode: .nearest, timeInterval: 0.1)
    }
    
    // Additions
    func addHealthBar(on node: SKNode) {
        
        let bar = SKSpriteNode(imageNamed: "healthBar")
        bar.size = GameConfiguration.worldConfiguration.tileSize
        bar.texture?.filteringMode = .nearest
        
        let underBar = SKSpriteNode(imageNamed: "emptyBar")
        underBar.size = GameConfiguration.worldConfiguration.tileSize
        underBar.texture?.filteringMode = .nearest
        
        let configuration = PKProgressBarNode.ImageConfiguration(sprite: bar,
                                                                 underSprite: underBar)
        let progressBar = PKProgressBarNode(imageConfiguration: configuration)
        progressBar.name = "Health Bar"
        progressBar.position = CGPoint(x: 0, y: node.frame.size.height / 2)
        
        node.addChildSafely(progressBar)
    }
    func addJumpTimerBar(on node: SKNode) {
        let bar = SKSpriteNode(imageNamed: "healthBar")
        bar.size = GameConfiguration.worldConfiguration.tileSize
        bar.texture?.filteringMode = .nearest
        
        let underBar = SKSpriteNode(imageNamed: "emptyBar")
        underBar.size = GameConfiguration.worldConfiguration.tileSize
        underBar.texture?.filteringMode = .nearest
        
        let configuration = PKProgressBarNode.ImageConfiguration(sprite: bar,
                                                                 underSprite: underBar)
        let progressBar = PKProgressBarNode(imageConfiguration: configuration)
        progressBar.name = "Health Bar"
        progressBar.position = CGPoint(x: 0, y: node.frame.size.height)
        
        node.addChildSafely(progressBar)
        
        let timerConfiguration = PKTimerNode.TimerConfiguration(
            countdown: 2,
            counter: 0.1,
            timeInterval: 0.1,
            actionOnGoing: {
                progressBar.decrease(by: 0.1, duration: 0.2)
            },
            actionOnEnd: {
                progressBar.removeFromParent()
            })
        
        let timerNode = PKTimerNode(configuration: timerConfiguration)
        
        progressBar.addChildSafely(timerNode)
        
        timerNode.start()
    }
    
    // States
    func pause() { /*container.isPaused = true*/ }
    func unpause() { /*container.isPaused = false*/ }
}
