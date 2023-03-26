//
//  CollisionLogic.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import SpriteKit
import PlayfulKit

public class CollisionLogic {
    
    public init(scene: GameScene) {
        self.scene = scene
    }
    
    public var scene: GameScene
    
    public func projectileHitObject(_ projectileNode: PKObjectNode, objectNode: PKObjectNode) {
        scene.core?.logic?.damageObject(objectNode, with: projectileNode)
        projectileNode.removeAllActions()
        scene.player?.isProjectileTurningBack = true
    }
    
    public func pickUpItem(object: PKObjectNode, name: String) {
        if let item = try? GameItem.get(name) {
            scene.player?.bag.append(item)
            scene.core?.hud?.updateScore()
            object.removeFromParent()
        }
    }
    
    public func enemyHitPlayer(_ enemyNode: PKObjectNode) {
        guard let player = scene.player else { return }
        scene.core?.logic?.damageObject(player.node, with: enemyNode)
        print("Enemy touch player")
    }
    
    public func landOnGround() {
        guard let player = scene.player else { return }
        
        if player.isJumping {
            player.isJumping = false
        }
    }
}
