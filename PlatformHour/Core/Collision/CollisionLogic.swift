//
//  CollisionLogic.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import SpriteKit
import PlayfulKit

final class CollisionLogic {
    
    init(scene: GameScene) {
        self.scene = scene
    }
    
    var scene: GameScene
    
    /// When the player projectile hit an object.
    func projectileHitObject(_ projectileNode: PKObjectNode, objectNode: PKObjectNode) {
        scene.core?.logic?.damageObject(objectNode, with: projectileNode)
        projectileNode.removeAllActions()
        scene.player?.state.hasProjectileTurningBack = true
    }
    
    /// When the player pick up an item.
    func pickUpCollectible(object: PKObjectNode) {
        if let objectName = object.name,
           let collectibleData = GameObject.getCollectible(objectName) {
            if let collectibleSound = collectibleData.sound {
                try? scene.core?.sound.manager.playSFX(name: collectibleSound, volume: 0.1)
            }
            scene.player?.bag.append(collectibleData)
            scene.core?.hud?.updateGemScore()
            scene.core?.animation?.delayedDestroy(scene: scene,
                                                  node: object,
                                                  timeInterval: 0.1)
        }
    }
    
    /// When the player drop on the head of an enemy.
    func playerDropOnEnemy(_ enemyNode: PKObjectNode) {
        guard let player = scene.player else { return }
        if player.state.isJumping {
            scene.core?.logic?.instantDestroy(enemyNode)
        }
    }
    
    /// When an enemy hit the player.
    func enemyHitPlayer(_ enemyNode: PKObjectNode) {
        //        guard let player = scene.player else { return }
        //        guard let environment = scene.core?.environment else { return }
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
    
    /// When the player land on a structure.
    func landOnGround() {
        guard let player = scene.player else { return }
        
        if player.state.isJumping {
            player.state.isJumping = false
        }
    }
}
