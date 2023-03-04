//
//  GameAnimation.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import SwiftUI
import SpriteKit
import PlayfulKit
import Utility_Toolbox

final public class GameAnimation {
    
    public init(scene: GameScene, dimension: GameDimension) {
        self.scene = scene
        self.dimension = dimension
    }
    
    public var manager = AnimationManager()
    public var scene: GameScene
    public var dimension: GameDimension
    
    public struct SpecialEffect {
        let image: String
        let frameCount: Int
    }
    
    public enum StateID: String {
        case idle = "idle"
        case hit = "hit"
        case death = "death"
    }
    
    public let spark = GameAnimation.SpecialEffect(image: "spark", frameCount: 3)
//    private var spark: SpecialEffect { SpecialEffect(image: "spark", frameCount: 3) }
//    private var crateDestruction: SpecialEffect { SpecialEffect(image: "crateShards", frameCount: 3) }
    
    public func effect(effect: SpecialEffect, at position: CGPoint, alpha: Double = 1) -> SKSpriteNode {
        let effect = SKSpriteNode()
        effect.alpha = alpha
        effect.size = dimension.tileSize * 1.2
        effect.position = position
        return effect
    }
    
    public func effectAnimation(effect: SpecialEffect,
                                timePerFrame: TimeInterval = 0.1,
                                count: Int = 1) -> SKAction {
        let images = Array(0..<effect.frameCount).map { effect.image + "\($0)" }
        let effectAnimation = SKAction.animate(with: images, filteringMode: .nearest, timePerFrame: timePerFrame)
        let action = SKAction.repeat(effectAnimation, count: count)
        let sequence = SKAction.sequence([
            action,
            SKAction.removeFromParent()
        ])
        return sequence
    }
    
    public func circularSmoke(on node: SKNode) {
        let frameCount = 8
        let images = Array(0..<frameCount).map { "circularSmoke" + "\($0)" }
        let size = CGSize(width: dimension.tileSize.width, height: dimension.tileSize.height * 0.3)
        let circularSmokeNode = SKSpriteNode()
        circularSmokeNode.size = size
        circularSmokeNode.position = CGPoint(x: node.position.x, y: node.position.y - dimension.tileSize.height * 0.35)
        let sequence = SKAction.sequence([
            SKAction.animate(with: images, filteringMode: .nearest, timePerFrame: 0.05),
            SKAction.removeFromParent()
        ])
        scene.addChild(circularSmokeNode)
        circularSmokeNode.run(sequence)
    }
    
    public func animate(node: PKObjectNode,
                        identifier: StateID,
                        filteringMode: SKTextureFilteringMode = .linear,
                        hitTimeInterval: TimeInterval = 0.05) -> SKAction {
        guard node.animation(from: identifier.rawValue) != nil else { return SKAction.empty() }
        let animation = node.animatedAction(with: identifier.rawValue,
                                            filteringMode: filteringMode,
                                            timeInterval: hitTimeInterval)
        return animation
    }
    
    public func hit(node: PKObjectNode,
                    filteringMode: SKTextureFilteringMode = .linear,
                    timeInterval: TimeInterval = 0.05) {
        node.run(animate(node: node,
                         identifier: .hit,
                         filteringMode: filteringMode,
                         hitTimeInterval: timeInterval))
    }
    
    public func destroy(node: PKObjectNode,
                        filteringMode: SKTextureFilteringMode = .linear,
                        timeInterval: TimeInterval = 0.05) {
        guard node.animation(from: StateID.death.rawValue) != nil else { return }
        
        let sequence = SKAction.sequence([
            animate(node: node,
                    identifier: .death,
                    filteringMode: filteringMode,
                    hitTimeInterval: timeInterval),
            SKAction.removeFromParent()
        ])
        node.run(sequence)
    }
}
