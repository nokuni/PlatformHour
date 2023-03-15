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
    
    public func effect(effect: SpecialEffect,
                       at position: CGPoint,
                       alpha: Double = 1) -> SKSpriteNode {
        let effect = SKSpriteNode()
        effect.alpha = alpha
        effect.size = GameApp.worldConfiguration.tileSize * 1.2
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
                        timeInterval: TimeInterval = 0.05, actionAfter: (() -> Void)?) {
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
