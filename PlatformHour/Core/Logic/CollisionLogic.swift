//
//  CollisionLogic.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import SpriteKit
import PlayfulKit

public class CollisionLogic {
    
    public init(scene: GameScene, animation: GameAnimation, logic: GameLogic) {
        self.scene = scene
        self.animation = animation
        self.logic = logic
    }
    
    public var scene: GameScene
    public var animation: GameAnimation
    public var logic: GameLogic
    
    public func projectileHitObject(_ projectileNode: PKObjectNode, objectNode: PKObjectNode) {
        logic.damageObject(objectNode, with: projectileNode)
    }
    
    public func landingOnground() {
        guard let player = scene.player else { return }
        player.node.physicsBody?.velocity = .zero
        
        if let controller = scene.game?.controller {
            if controller.action.isJumping {
                controller.action.isJumping = false
                scene.core?.animation?.circularSmoke(on: player.node)
            }
        }
    }
}
