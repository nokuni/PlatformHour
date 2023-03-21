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
    
    public func circularSmoke(on node: SKNode) {
        let tileSize = GameConfiguration.worldConfiguration.tileSize
        let animationNode = SKSpriteNode()
        animationNode.size = CGSize(width: tileSize.width * 2, height: tileSize.height)
        
        let animation = SKAction.animate(with: GameConfiguration.animationConfiguration.circularSmoke, filteringMode: .nearest, timePerFrame: 0.1)
        
        let sequence = SKAction.sequence([
            animation,
            SKAction.removeFromParent()
        ])
        
        node.addChildSafely(animationNode)
        
        animationNode.run(sequence)
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
