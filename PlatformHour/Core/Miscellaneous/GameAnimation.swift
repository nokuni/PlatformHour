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
    
    public init() { }
    
    public struct SpecialEffect {
        let image: String
        let frameCount: Int
    }
    public enum StateID: String {
        case idle = "idle"
        case hit = "hit"
        case death = "death"
    }
    
    public func addGravityEffect(on node: SKNode) {
        let gravityEffectNode = SKSpriteNode()
        gravityEffectNode.name = GameConfiguration.sceneConfigurationKey.gravityEffect
        gravityEffectNode.size = GameConfiguration.worldConfiguration.tileSize
        node.addChildSafely(gravityEffectNode)
        
        let effects = GameConfiguration.animationConfiguration.gravityEffects
        
        let actions = effects.map {
            SKAction.animate(with: $0, filteringMode: .nearest, timePerFrame: 0.05)
        }
        
        guard !actions.isEmpty else { return }
        guard actions.count == effects.count else { return }
        
        let animation = SKAction.sequence([
            actions[0],
            actions[1],
            actions[2]
        ])
        
        gravityEffectNode.run(SKAction.repeatForever(animation))
    }
    
    public func transitionEffect(effect: SKAction,
                                 isVisible: Bool = true,
                                 scene: GameScene,
                                 completion: (() -> Void)?) {
        scene.isUserInteractionEnabled = false
        let effectNode = SKShapeNode(rectOf: scene.size * 2)
        effectNode.alpha = isVisible ? 1 : 0
        effectNode.fillColor = .black
        effectNode.strokeColor = .black
        effectNode.zPosition = GameConfiguration.worldConfiguration.overlayZPosition
        effectNode.position = scene.player?.node.position ?? .zero
        scene.addChild(effectNode)
        let sequence = SKAction.sequence([
            effect,
            SKAction.run {
                effectNode.removeFromParent()
                scene.isUserInteractionEnabled = true
                completion?()
            }
        ])
        effectNode.run(sequence)
    }
    
    public func circularSmoke(on node: SKNode) {
        let tileSize = GameConfiguration.worldConfiguration.tileSize
        let animationNode = SKSpriteNode()
        animationNode.size = CGSize(width: tileSize.width * 2, height: tileSize.height)
        
        let animation = SKAction.animate(with: GameConfiguration.animationConfiguration.circularSmoke, filteringMode: .nearest, timePerFrame: 0.05)
        
        let sequence = SKAction.sequence([
            animation,
            SKAction.removeFromParent()
        ])
        
        node.addChildSafely(animationNode)
        
        animationNode.run(sequence)
    }
    
    public func destroyThenAnimate(scene: GameScene,
                                   node: PKObjectNode,
                                   timeInterval: TimeInterval = 0.05,
                                   actionAfter: (() -> Void)? = nil) {
        let animatedNode = PKObjectNode()
        animatedNode.size = node.size
        animatedNode.zPosition = GameConfiguration.worldConfiguration.objectZPosition
        animatedNode.position = node.position
        animatedNode.animations = node.animations
        
        scene.addChildSafely(animatedNode)
        
        let sequence = SKAction.sequence([
            animate(node: animatedNode,
                    identifier: .death,
                    filteringMode: .nearest,
                    hitTimeInterval: timeInterval),
            SKAction.removeFromParent(),
        ])
        
        SKAction.start(actionOnLaunch: nil, animation: sequence, node: animatedNode, actionOnEnd: actionAfter)
        
        node.removeFromParent()
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
    
    public func idle(node: PKObjectNode,
                     filteringMode: SKTextureFilteringMode = .linear,
                     timeInterval: TimeInterval = 0.05) {
        let action = animate(node: node,
                             identifier: .idle,
                             filteringMode: filteringMode,
                             hitTimeInterval: timeInterval)
        
        node.run(SKAction.repeatForever(action))
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
                        timeInterval: TimeInterval = 0.05,
                        actionAfter: (() -> Void)? = nil) {
        guard node.animation(from: StateID.death.rawValue) != nil else { return }
        
        let sequence = SKAction.sequence([
            animate(node: node,
                    identifier: .death,
                    filteringMode: filteringMode,
                    hitTimeInterval: timeInterval),
            SKAction.removeFromParent(),
        ])
        
        SKAction.start(actionOnLaunch: nil, animation: sequence, node: node, actionOnEnd: actionAfter)
    }
}
