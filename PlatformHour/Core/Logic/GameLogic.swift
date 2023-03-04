//
//  GameLogic.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 05/02/23.
//

import SpriteKit
import PlayfulKit
import Utility_Toolbox

final public class GameLogic {
    
    public init(scene: GameScene, animation: GameAnimation) {
        self.scene = scene
        self.animation = animation
    }
    
    public var scene: GameScene
    public var animation: GameAnimation
    
    public func damageObject(_ objectNode: PKObjectNode, with projectileNode: PKObjectNode) {
        guard objectNode.logic.isDestructible else { return }
        objectNode.logic.healthLost += projectileNode.logic.damage
        damage(objectNode)
    }
    
    private func isDestroyed(_ objectNode: PKObjectNode) -> Bool {
        objectNode.logic.healthLost >= objectNode.logic.health
    }
    
    private func destroy(_ objectNode: PKObjectNode) {
        if isDestroyed(objectNode) {
            objectNode.physicsBody?.categoryBitMask = .zero
            objectNode.physicsBody?.contactTestBitMask = .zero
            objectNode.physicsBody?.collisionBitMask = .zero
            scene.animation?.destroy(node: objectNode,
                                     filteringMode: .nearest)
        }
    }
    
    private func hit(_ objectNode: PKObjectNode) {
        scene.animation?.hit(node: objectNode,
                             filteringMode: .nearest)
    }
    
    private func damage(_ objectNode: PKObjectNode) {
        hit(objectNode)
        destroy(objectNode)
    }
}
