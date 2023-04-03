//
//  CollisionLogic.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import SpriteKit
import PlayfulKit

public final class CollisionLogic {
    
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
            try? scene.core?.sound.manager.playSFX(name: item.sound, volume: 0.1)
            scene.player?.bag.append(item)
            scene.core?.hud?.updateScore()
            scene.core?.animation?.destroyThenAnimate(scene: scene,
                                                      node: object,
                                                      timeInterval: 0.1)
        }
    }
    
    public func playerDropOnEnemy(_ enemyNode: PKObjectNode) {
        guard let player = scene.player else { return }
        if player.isJumping {
            scene.core?.logic?.instantDestroy(enemyNode)
        }
    }
    
    public func enemyHitPlayer(_ enemyNode: PKObjectNode) {
        guard let player = scene.player else { return }
        guard let environment = scene.core?.environment else { return }
        self.scene.core?.logic?.damagePlayer(with: enemyNode)
//        player.hitted(scene: scene, by: enemyNode) {
//            if let playerCoordinate = self.scene.player?.node.coordinate {
//                let groundCoordinate = Coordinate(x: playerCoordinate.x + 1, y: playerCoordinate.y)
//                if !environment.isCollidingWithObject(at: groundCoordinate) {
//                    self.scene.core?.logic?.dropPlayer()
//                }
//                self.scene.core?.logic?.endSequenceAction()
//                self.scene.core?.logic?.damagePlayer(with: enemyNode)
//                self.scene.player?.state = .normal
//                self.scene.core?.logic?.enableControls()
//            }
//        }
    }
    
    public func landOnGround() {
        guard let player = scene.player else { return }
        
        if player.isJumping {
            player.isJumping = false
        }
    }
}
