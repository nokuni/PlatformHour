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
        configurePlayer()
        createPlayer()
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
        guard let player = scene.player else { return PKObjectNode() }
        let currentRoll = player.currentRoll.rawValue
        
        let collision = Collision(category: .playerProjectile,
                                  collision: [.allClear],
                                  contact: [.object, .structure])
        
        let attackNode = object(name: "Player Projectile",
                                physicsBodySizeTailoring: -(CGSize.screen.height * 0.1),
                                collision: collision)
        
        attackNode.logic.damage = currentRoll
        attackNode.texture = SKTexture(imageNamed: player.node.texture?.name ?? "")
        attackNode.texture?.filteringMode = .nearest
        attackNode.coordinate = player.node.coordinate
        attackNode.position = player.node.position
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
    
    // Setups
    
    func configurePlayer() {
        let collision = Collision(category: .player,
                                  collision: [.structure],
                                  contact: [.enemyProjectile, .object])
        scene.player?.node = object(name: "Player",
                                   physicsBodySizeTailoring: -dimension.tileSize.width * 0.1,
                                   collision: collision)
        
        scene.player?.node.physicsBody?.friction = 0
        scene.player?.node.physicsBody?.allowsRotation = false
        scene.player?.node.physicsBody?.affectedByGravity = false
        
        if let player = scene.player {
            addArrow("arrowRight", named: "Player Arrow", on: player.node)
        }
        
        scene.player?.node.coordinate = scene.game?.playerCoordinate ?? .zero
        scene.player?.node.position = environment.map.tilePosition(from: scene.game?.playerCoordinate ?? .zero) ?? .zero
        scene.player?.node.texture = SKTexture(imageNamed: "playerIdle0")
        scene.player?.node.texture?.filteringMode = .nearest
    }
    
    // Creations
    private func createPlayer() {
        if let player = scene.player {
            scene.addChild(player.node)
        }
    }
    
    // Additions
    func addArrow(_ image: String, named name: String, on node: SKNode) {
        let arrow = arrow(image, named: name)
        arrow.position = CGPoint(x: 0, y: node.frame.size.height / 2)
        node.addChild(arrow)
    }
    
    // States
    func pause() { /*container.isPaused = true*/ }
    func unpause() { /*container.isPaused = false*/ }
}
