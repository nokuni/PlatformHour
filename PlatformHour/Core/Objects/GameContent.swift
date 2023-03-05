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
         dimension: GameDimension,
         environment: GameEnvironment,
         animation: GameAnimation) {
        self.scene = scene
        self.dimension = dimension
        self.environment = environment
        self.animation = animation
        spawn()
        //createContent()
    }
    
    var scene: GameScene
    var dimension: GameDimension
    var environment: GameEnvironment
    var animation: GameAnimation
    
    private func createContent() {
        createPlayer()
    }
    
    // Objects
    public func object(name: String? = nil,
                       physicsBodySizeTailoring: CGFloat = 0,
                       collision: Collision) -> PKObjectNode {
        
        let object = PKObjectNode()
        object.name = name
        object.size = dimension.tileSize
        
        object.applyPhysicsBody(
            size: object.size + physicsBodySizeTailoring,
            collision: collision
        )
        
        return object
    }
    public var projectileNode: PKObjectNode {
        let currentRoll = scene.player.currentRoll.rawValue
        
        let collision = Collision(category: .playerProjectile,
                                  collision: [.allClear],
                                  contact: [.object, .structure])
        
        let attackNode = object(name: "Player Projectile",
                                physicsBodySizeTailoring: -(CGSize.screen.height * 0.1),
                                collision: collision)
        
        attackNode.logic.damage = currentRoll
        attackNode.texture = SKTexture(imageNamed: scene.player.node.texture?.name ?? "")
        attackNode.coordinate = scene.player.node.coordinate
        attackNode.position = scene.player.node.position
        attackNode.alpha = 0.5
        
        attackNode.physicsBody?.affectedByGravity = false
        attackNode.physicsBody?.restitution = -10
        attackNode.physicsBody?.friction = 0
        attackNode.physicsBody?.allowsRotation = false
        
        return attackNode
    }
    
    // Sprites
    func arrow(_ image: String, named name: String) -> SKSpriteNode {
        let arrowNode = SKSpriteNode(imageNamed: image)
        arrowNode.name = name
        arrowNode.texture?.filteringMode = .nearest
        arrowNode.size = dimension.tileSize
        
        return arrowNode
    }
    
    func spawn() {
        let position = environment.map.tilePosition(from: scene.game?.playerCoordinate ?? .zero) ?? .zero
        let effect = animation.effect(effect: animation.spark, at: position, alpha: 0.5)
        scene.addChild(effect)
        let sequence = SKAction.sequence([
            animation.effectAnimation(effect: animation.spark, timePerFrame: 0.05, count: 5),
            SKAction.run { self.createPlayer() }
        ])
        effect.run(sequence)
    }
    
    // Creations
    private func createPlayer() {
        
        let collision = Collision(category: .player,
                                  collision: [.structure, .object],
                                  contact: [.enemyProjectile])
        scene.player.node = object(name: "Player",
                                   physicsBodySizeTailoring: -dimension.tileSize.width * 0.1,
                                   collision: collision)
        
        scene.player.node.physicsBody?.friction = 0
        scene.player.node.physicsBody?.allowsRotation = false
        scene.player.node.physicsBody?.affectedByGravity = false
        
        addArrow("arrowRight", named: "Player Arrow", on: scene.player.node)
        
        scene.player.node.coordinate = scene.game?.playerCoordinate ?? .zero
        scene.player.node.position = environment.map.tilePosition(from: scene.game?.playerCoordinate ?? .zero) ?? .zero
        scene.player.node.texture = SKTexture(imageNamed: "playerIdle0")
        scene.player.node.texture?.filteringMode = .nearest
        scene.addChild(scene.player.node)
    }
    
    // Additions
    func addArrow(_ image: String, named name: String, on node: SKNode) {
        let arrow = arrow(image, named: name)
        arrow.position = CGPoint(x: 0, y: node.frame.size.height)
        node.addChild(arrow)
    }
    
    // States
    func pause() { /*container.isPaused = true*/ }
    func unpause() { /*container.isPaused = false*/ }
}
