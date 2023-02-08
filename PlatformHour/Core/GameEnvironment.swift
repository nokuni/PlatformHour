//
//  GameEnvironment.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import SpriteKit
import PlayfulKit

final public class GameEnvironment {
    
    init(scene: SKScene) {
        self.scene = scene
        createEnvironment()
    }
    
    var scene: SKScene?
    
    func createEnvironment() {
        guard let scene = scene as? GameScene else { return }
        let environmentNode = SKNode()
        environmentNode.name = "Game Environment"
        scene.addChild(environmentNode)
        createBackground(on: environmentNode)
        createGround(on: environmentNode)
    }
    
    func groundTile(named name: String) -> SKSpriteNode {
        guard let scene = scene as? GameScene else { return SKSpriteNode() }
        guard let dimension = scene.dimension else { return SKSpriteNode() }
        guard let collision = scene.collision else { return SKSpriteNode() }
        
        let groundTileNode = SKSpriteNode(imageNamed: name)
        groundTileNode.texture?.filteringMode = .nearest
        groundTileNode.size = dimension.tileSize
        
        groundTileNode.physicsBody = SKPhysicsBody(rectangleOf: groundTileNode.size)
        groundTileNode.physicsBody?.isDynamic = false
        groundTileNode.physicsBody?.affectedByGravity = false
        
        groundTileNode.physicsBody?.categoryBitMask = collision.wallMask
        groundTileNode.physicsBody?.collisionBitMask = collision.playerMask
        groundTileNode.physicsBody?.contactTestBitMask = collision.playerMask
        
        return groundTileNode
    }
    
    func createGround(on node: SKNode) {
        guard let scene = scene as? GameScene else { return }
        guard let dimension = scene.dimension else { return }
        let startingPoint = CGPoint(x: scene.frame.minX, y: scene.frame.minY)
        var ground: [SKSpriteNode] = []
        var count = 59
        
        for index in 0..<300 {
            var tile = SKSpriteNode()
            switch true {
            case index == 0: tile = groundTile(named: "templeTopLeftGround")
            case index > 0 && index < 29: tile = groundTile(named: "templeTopGround")
            case index == 29: tile = groundTile(named: "templeTopRightGround")
            case index % 30 == 0: tile = groundTile(named: "templeMiddleLeftGround")
            case index == count:
                tile = groundTile(named: "templeMiddleRightGround")
                count += 30
            default: tile = groundTile(named: "templeMiddleGround")
            }
            ground.append(tile)
        }
        
        dimension.kit.createSpriteCollection(of: ground, at: startingPoint, in: node, axes: .horizontal, alignment: .leading, horizontalSpacing: 1, verticalSpacing: 1, maximumLineCount: 30)
    }
    func createBackground(on node: SKNode) {
        let darkBlue = UIColor(red: 39/255, green: 68/255, blue: 58/255, alpha: 1)
        let blue = UIColor(red: 101/255, green: 179/255, blue: 152/255, alpha: 1)
        
        let imageRect = CGRect(x: CGPoint.center.x, y: CGPoint.center.y, width: CGSize.screen.width * 5, height: CGSize.screen.height * 5)
        
        let texture = SKTexture.gradient(rect: imageRect, points: .topToBottom, colors: [darkBlue, blue])
        
        let gradientNode = SKSpriteNode(texture: texture)
        gradientNode.position = CGPoint.center
        node.addChild(gradientNode)
    }
}
