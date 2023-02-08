//
//  GameContent.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import SpriteKit

final public class GameContent {
    
    init(scene: SKScene) {
        self.scene = scene
        createContent()
    }
    
    var scene: SKScene?
    var entrancePortal = SKSpriteNode()
    var exitPortal = SKSpriteNode()
    
    var all: SKNode? {
        return scene?.childNode(withName: "Game Content")
    }
    
    func createContent() {
        let contentNode = SKNode()
        contentNode.name = "Game Content"
        scene?.addChild(contentNode)
        createObjects(on: contentNode)
        createPortals(on: contentNode)
        animateEntrancePortal(on: contentNode)
    }
    
    func createPlayer(on node: SKNode) {
        guard let scene = scene as? GameScene else { return }
        guard let dimension = scene.dimension else { return }
        guard let collision = scene.collision else { return }
        
        scene.player.node = SKSpriteNode(imageNamed: "playerIdle0")
        scene.player.node.name = "Player"
        scene.player.node.texture?.filteringMode = .nearest
        scene.player.node.size = dimension.tileSize
        scene.player.node.zPosition = 0
        scene.player.node.position = CGPoint(x: scene.frame.minX + dimension.tileSize.width, y: scene.frame.minY + dimension.tileSize.height)
        
        scene.player.node.physicsBody = SKPhysicsBody(rectangleOf: scene.player.node.size)
        
        scene.player.node.physicsBody?.restitution = -10
        scene.player.node.physicsBody?.friction = 0
        scene.player.node.physicsBody?.allowsRotation = false
        scene.player.node.physicsBody?.angularDamping = 0
        scene.player.node.physicsBody?.angularVelocity = 0
        scene.player.node.physicsBody?.usesPreciseCollisionDetection = true
        
        scene.player.node.physicsBody?.categoryBitMask = collision.playerMask
        scene.player.node.physicsBody?.collisionBitMask = collision.wallMask | collision.objectMask
        scene.player.node.physicsBody?.contactTestBitMask = collision.objectMask
        
        node.addChild(scene.player.node)
    }
    func createdObject(named name: String) -> SKSpriteNode? {
        guard let scene = scene as? GameScene else { return nil }
        guard let dimension = scene.dimension else { return nil }
        guard let collision = scene.collision else { return nil }
        
        let object = SKSpriteNode(imageNamed: name)
        object.name = name
        object.texture?.filteringMode = .nearest
        object.size = dimension.tileSize
        
        object.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 50))
        object.physicsBody?.isDynamic = false
        object.physicsBody?.categoryBitMask = collision.objectMask
        object.physicsBody?.collisionBitMask = collision.playerMask
        object.physicsBody?.contactTestBitMask = collision.playerMask | collision.wallMask
        object.physicsBody?.usesPreciseCollisionDetection = true
        
        return object
    }
    func portal(named name: String) -> SKSpriteNode {
        guard let scene = scene as? GameScene else { return SKSpriteNode() }
        guard let dimension = scene.dimension else { return SKSpriteNode() }
        guard let collision = scene.collision else { return SKSpriteNode() }
        
        let portalNode = SKSpriteNode(imageNamed: "\(name)0")
        portalNode.texture?.filteringMode = .nearest
        portalNode.size = dimension.tileSize
        
        portalNode.physicsBody = SKPhysicsBody(rectangleOf: portalNode.size)
        portalNode.physicsBody?.isDynamic = false
        portalNode.physicsBody?.affectedByGravity = false
        
        portalNode.physicsBody?.categoryBitMask = collision.wallMask
        portalNode.physicsBody?.collisionBitMask = collision.playerMask
        portalNode.physicsBody?.contactTestBitMask = collision.playerMask
        
        return portalNode
    }
    
    func animateEntrancePortal(on node: SKNode) {
        guard let scene = scene as? GameScene else { return }
        guard let dimension = scene.dimension else { return }
        guard let animation = scene.animation else { return }
        
        let counts = Array(0..<3).reversed()
        let images = counts.map { "whitePortal\($0)" }
        let portalAnimation = animation.kit.spriteAnimation(images: images, filteringMode: .nearest, timePerFrame: 0.05)
        let portalEntranceAnimation = SKAction.repeat(portalAnimation, count: 10)
        
        let sequence = SKAction.sequence([
            SKAction.run {
                animation.spark(at: CGPoint(x: scene.frame.minX + dimension.tileSize.width, y: scene.frame.minY + (dimension.tileSize.height * 0.7)), timePerFrame: 0.05, count: 10)
            },
            portalEntranceAnimation,
            SKAction.run {
                scene.content?.createPlayer(on: node)
            }
        ])
        entrancePortal.run(sequence)
    }
    func createPortals(on node: SKNode) {
        guard let scene = scene as? GameScene else { return }
        guard let dimension = scene.dimension else { return }
        
        entrancePortal = portal(named: "whitePortal")
        entrancePortal.position = CGPoint(x: scene.frame.minX - dimension.tileSize.width, y: scene.frame.minY + dimension.tileSize.height)
        scene.addChild(entrancePortal)
        
        exitPortal = portal(named: "redPortal")
        exitPortal.name = "Exit Portal"
        exitPortal.xScale = -1
        exitPortal.position = CGPoint(x: scene.frame.minX + (dimension.tileSize.width * 30), y: scene.frame.minY + dimension.tileSize.height)
        node.addChild(exitPortal)
    }
    func createObjects(on node: SKNode) {
        
        guard let scene = scene as? GameScene else { return }
        guard let dimension = scene.dimension else { return }
        
        let startingPosition = CGPoint(x: scene.frame.minX + (dimension.tileSize.width * 5), y: scene.frame.minY + (dimension.tileSize.height * 3))
        var objectNodes: [SKSpriteNode] = []
        
        let numbers = [5, 2, 3, 4, 1, 6]
        
        for index in numbers {
            if let objectNode = createdObject(named: "diceBox\(index - 1)") {
                objectNodes.append(objectNode)
            }
        }
        
        dimension.kit.createSpriteList(of: objectNodes, at: startingPosition, in: node, axes: .horizontal, alignment: .leading, spacing: 3)
    }
    
    func pause() { all?.isPaused = true }
    func unpause() { all?.isPaused = false }
}
