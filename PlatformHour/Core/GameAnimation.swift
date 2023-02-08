//
//  GameAnimation.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import SwiftUI
import SpriteKit
import PlayfulKit

class GameAnimation {
    
    init(scene: SKScene) {
        self.scene = scene
    }
    
    var kit = PKAnimation()
    var scene: SKScene?
    
    func spark(at position: CGPoint, timePerFrame: TimeInterval = 0.05, count: Int = 1) {
        guard let scene = scene as? GameScene else { return }
        guard let dimension = scene.dimension else { return }
        let frameCount = 3
        let images = Array(0..<frameCount).map { "spark" + "\($0)" }
        let spark = SKSpriteNode()
        spark.size = dimension.tileSize
        spark.position = CGPoint(x: position.x, y: position.y + 10)
        let sparkAnimation = kit.spriteAnimation(images: images, filteringMode: .nearest, timePerFrame: timePerFrame)
        let action = SKAction.repeat(sparkAnimation, count: count)
        let sequence = SKAction.sequence([
            action,
            SKAction.removeFromParent()
        ])
        scene.addChild(spark)
        spark.run(sequence)
    }
    
    func circularSmoke(on node: SKNode) {
        guard let scene = scene as? GameScene else { return }
        guard let dimension = scene.dimension else { return }
        let animation = PKAnimation()
        let frameCount = 8
        let images = Array(0..<frameCount).map { "circularSmoke" + "\($0)" }
        let size = CGSize(width: dimension.tileSize.width, height: dimension.tileSize.height * 0.3)
        let circularSmokeNode = SKSpriteNode()
        circularSmokeNode.size = size
        circularSmokeNode.position = CGPoint(x: node.position.x, y: node.position.y - dimension.tileSize.height * 0.35)
        let sequence = SKAction.sequence([
            animation.spriteAnimation(images: images, filteringMode: .nearest, timePerFrame: 0.05),
            SKAction.removeFromParent()
        ])
        scene.addChild(circularSmokeNode)
        circularSmokeNode.run(sequence)
    }
    
    func roll() {
        
    }
}
