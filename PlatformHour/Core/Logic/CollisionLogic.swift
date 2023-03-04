//
//  CollisionLogic.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import SpriteKit
import PlayfulKit

class CollisionLogic {
    
    public init(scene: GameScene, game: Game, animation: GameAnimation, logic: GameLogic) {
        self.scene = scene
        self.game = game
        self.animation = animation
        self.logic = logic
    }
    
    public var scene: GameScene
    public var game: Game
    public var animation: GameAnimation
    public var logic: GameLogic
    
    public func projectileHitObject(_ projectileNode: PKObjectNode, objectNode: PKObjectNode) {
        let effect = animation.effect(effect: animation.spark, at: projectileNode.position, alpha: 0.5)
        scene.addChild(effect)
        let collisionAnimation = animation.effectAnimation(effect: animation.spark, timePerFrame: 0.05)
        effect.run(collisionAnimation)
        logic.damageObject(objectNode, with: projectileNode)
    }
    
    public func landingOnground() {
        scene.player.node.physicsBody?.velocity = .zero
        
        if let controller = game.controller {
            if controller.action.isJumping {
                controller.action.isJumping = false
                controller.virtualController.hasPressedAnyInput = false
                scene.animation?.circularSmoke(on: scene.player.node)
            }
        }
    }
}
