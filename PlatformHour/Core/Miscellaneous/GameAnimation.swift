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
        case run = "run"
        case hit = "hit"
        case death = "death"
    }
    
    /// Shake the screen.
    public func shakeScreen(scene: GameScene) {
        guard let camera = scene.camera else { return }
        let shake = SKAction.shake(duration: 0.1, amplitudeX: 25, amplitudeY: 25)
        SKAction.start(actionOnLaunch: {
            scene.core?.gameCamera?.isFollowingPlayer = false
        }, animation: shake, node: camera) {
            scene.core?.gameCamera?.isFollowingPlayer = true
        }
    }
    
    /// Add a gravityt effect on a node.
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
    
    /// Scene transition effect.
    public func transitionEffect(effect: SKAction,
                                 isVisible: Bool = true,
                                 scene: GameScene,
                                 completion: (() -> Void)?) {
        scene.isUserInteractionEnabled = false
        let effectNode = SKShapeNode(rectOf: scene.size * 2)
        effectNode.alpha = isVisible ? 1 : 0
        effectNode.fillColor = .black
        effectNode.strokeColor = .black
        effectNode.zPosition = GameConfiguration.sceneConfiguration.overlayZPosition
        effectNode.position = scene.player?.node.position ?? .zero
        scene.addChild(effectNode)
        let sequence = SKAction.sequence([
            effect,
            SKAction.run {
                scene.isUserInteractionEnabled = true
                completion?()
            }
        ])
        effectNode.run(sequence)
    }
    
    /// Circular smoke animation.
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
    
    public func orbSplitEffect(scene: GameScene, on position: CGPoint) {
        let tileSize = GameConfiguration.worldConfiguration.tileSize
        let positions = [
            CGPoint(x: position.x, y: position.y + tileSize.height),
            CGPoint(x: position.x + tileSize.width, y: position.y + tileSize.height),
            CGPoint(x: position.x + tileSize.width, y: position.y),
            CGPoint(x: position.x + tileSize.width, y: position.y - tileSize.height),
            CGPoint(x: position.x, y: position.y - tileSize.height),
            CGPoint(x: position.x - tileSize.width, y: position.y - tileSize.height),
            CGPoint(x: position.x - tileSize.width, y: position.y),
            CGPoint(x: position.x - tileSize.width, y: position.y + tileSize.height),
        ]
        for pos in positions {
            let orb = SKSpriteNode(imageNamed: "orb0")
            orb.size = tileSize
            orb.texture?.filteringMode = .nearest
            orb.zPosition = GameConfiguration.sceneConfiguration.hudZPosition
            orb.position = position
            scene.addChildSafely(orb)
            
            let scale = SKAction.scaleUpAndDown(from: 0.1,
                                                with: 0.05,
                                                to: 1,
                                                with: 0.05,
                                                during: 0,
                                                repeating: 10)
            let fade = SKAction.fadeOut(withDuration: 0.5)
            let move = SKAction.move(to: pos, duration: 0.5)
            let groupAnimation = SKAction.group([scale, fade, move])
            
            let sequenceAnimation = SKAction.sequence([
                groupAnimation,
                SKAction.removeFromParent()
            ])
            
            orb.run(sequenceAnimation)
        }
    }
    
    /// Remove a node then animate the removal.
    public func destroyThenAnimate(scene: GameScene,
                                   node: PKObjectNode,
                                   timeInterval: TimeInterval = 0.05,
                                   actionAfter: (() -> Void)? = nil) {
        let animatedNode = PKObjectNode()
        animatedNode.size = node.size
        animatedNode.zPosition = GameConfiguration.sceneConfiguration.objectZPosition
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
    
    /// Animate a node with a state identifier.
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
    
    /// Animate a node with an idle state identifier.
    public func idle(node: PKObjectNode,
                     filteringMode: SKTextureFilteringMode = .linear,
                     timeInterval: TimeInterval = 0.05) {
        let action = animate(node: node,
                             identifier: .idle,
                             filteringMode: filteringMode,
                             hitTimeInterval: timeInterval)
        
        node.run(SKAction.repeatForever(action))
    }
    
    /// Animate a node with a hit state identifier.
    public func hit(node: PKObjectNode,
                    filteringMode: SKTextureFilteringMode = .linear,
                    timeInterval: TimeInterval = 0.05) {
        node.run(animate(node: node,
                         identifier: .hit,
                         filteringMode: filteringMode,
                         hitTimeInterval: timeInterval))
    }
    
    /// Animate a node with an death state identifier.
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
