//
//  GameCollision.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import SpriteKit
import PlayfulKit
import Utility_Toolbox

final class GameCollision {
    
    init(scene: GameScene) {
        self.scene = scene
        self.collisionLogic = CollisionLogic(scene: scene)
    }
    
    var scene: GameScene
    var collisionLogic: CollisionLogic
    
    var manager = CollisionManager()
    
    /// All collisions on the current scene.
    func all(firstBody: SKPhysicsBody, secondBody: SKPhysicsBody) {
        
        projectileTouchStructure(
            CollisionManager.NodeBody(body: firstBody,
                                      bitmaskCategory: CollisionCategory.playerProjectile.rawValue),
            with: CollisionManager.NodeBody(body: secondBody,
                                            bitmaskCategory: CollisionCategory.structure.rawValue)
        )
        
        playerTouchCollectible(
            CollisionManager.NodeBody(body: firstBody, bitmaskCategory: CollisionCategory.player.rawValue),
            with: CollisionManager.NodeBody(body: secondBody, bitmaskCategory: CollisionCategory.item.rawValue)
        )
        
        playerTouchInteractive(
            CollisionManager.NodeBody(body: firstBody, bitmaskCategory: CollisionCategory.player.rawValue),
            with: CollisionManager.NodeBody(body: secondBody, bitmaskCategory: CollisionCategory.object.rawValue)
        )
        
        keyTouchLock(
            CollisionManager.NodeBody(body: firstBody, bitmaskCategory: CollisionCategory.npc.rawValue),
            with: CollisionManager.NodeBody(body: secondBody, bitmaskCategory: CollisionCategory.object.rawValue)
        )
        
        playerOnExit(
            CollisionManager.NodeBody(body: firstBody, bitmaskCategory: CollisionCategory.player.rawValue),
            with: CollisionManager.NodeBody(body: secondBody, bitmaskCategory: CollisionCategory.npc.rawValue)
        )
        
        playerOnBlueCrystal(
            CollisionManager.NodeBody(body: firstBody, bitmaskCategory: CollisionCategory.player.rawValue),
            with: CollisionManager.NodeBody(body: secondBody, bitmaskCategory: CollisionCategory.npc.rawValue)
        )
        
        playerTouchGround(
            CollisionManager.NodeBody(body: firstBody, bitmaskCategory: CollisionCategory.player.rawValue),
            with: CollisionManager.NodeBody(body: secondBody, bitmaskCategory: CollisionCategory.structure.rawValue)
        )
        
        enemyTouchPlayer(
            CollisionManager.NodeBody(body: firstBody, bitmaskCategory: CollisionCategory.player.rawValue),
            with: CollisionManager.NodeBody(body: secondBody, bitmaskCategory: CollisionCategory.enemy.rawValue)
        )
        
        playerTouchEnemy(
            CollisionManager.NodeBody(body: firstBody, bitmaskCategory: CollisionCategory.player.rawValue),
            with: CollisionManager.NodeBody(body: secondBody, bitmaskCategory: CollisionCategory.enemy.rawValue)
        )
    }
}

// MARK: - Touchs

extension GameCollision {
    
    /// When the player collides with the ground of a structure.
    private func playerTouchGround(_ first: CollisionManager.NodeBody,
                                   with second: CollisionManager.NodeBody) {
        if manager.isColliding(first, with: second) {
            collisionLogic.landOnGround()
        }
    }
    
    /// When the player collides with the ground of a structure.
    private func enemyTouchPlayer(_ first: CollisionManager.NodeBody,
                                  with second: CollisionManager.NodeBody) {
        guard let enemyNode = second.body.node as? PKObjectNode else { return }
        if manager.isColliding(first, with: second) {
            collisionLogic.enemyHitPlayer(enemyNode)
        }
    }
    
    /// When the player collides with an enemy.
    private func playerTouchEnemy(_ first: CollisionManager.NodeBody,
                                  with second: CollisionManager.NodeBody) {
        guard let enemyNode = second.body.node as? PKObjectNode else { return }
        if manager.isColliding(first, with: second) {
            collisionLogic.playerDropOnEnemy(enemyNode)
        }
    }
    
    /// When the player projectile collides with a structure.
    private func projectileTouchStructure(_ first: CollisionManager.NodeBody,
                                          with second: CollisionManager.NodeBody) {
        guard let projectile = first.body.node as? PKObjectNode else { return }
        if manager.isColliding(first, with: second) {
            projectile.removeAllActions()
            scene.player?.state.hasProjectileTurningBack = true
        }
    }
    
    /// When the player collides with a collectible.
    private func playerTouchCollectible(_ first: CollisionManager.NodeBody,
                                        with second: CollisionManager.NodeBody) {
        guard let object = second.body.node as? PKObjectNode else { return }
        if manager.isColliding(first, with: second) {
            collisionLogic.pickUpCollectible(object: object)
        }
    }
    
    /// When the player collides with an interactive object.
    private func playerTouchInteractive(_ first: CollisionManager.NodeBody,
                                        with second: CollisionManager.NodeBody) {
        guard let object = second.body.node as? PKObjectNode else { return }
        if manager.isColliding(first, with: second) {
            collisionLogic.resetInteractiveObjectPosition(object: object)
        }
    }
    
    /// When a key collides with a lock.
    private func keyTouchLock(_ first: CollisionManager.NodeBody,
                              with second: CollisionManager.NodeBody) {
        guard let lock = first.body.node as? PKObjectNode else { return }
        guard let lockName = lock.name else { return }
        guard lockName.contains("Lock") else { return }
        guard let key = second.body.node as? PKObjectNode else { return }
        guard let keyName = key.name else { return }
        guard keyName.contains("Key") else { return }
        if manager.isColliding(first, with: second) {
            collisionLogic.keyOpenLock(key: key, lock: lock)
        }
    }
}

// MARK: - Coordinates

extension GameCollision {
    
    /// When the player is on the coordinate of the exit.
    private func playerOnExit(_ first: CollisionManager.NodeBody,
                              with second: CollisionManager.NodeBody) {
        guard let object = second.body.node as? PKObjectNode else { return }
        guard object.name == GameConfiguration.nodeKey.exit else { return }
        if manager.isColliding(first, with: second) {
            scene.core?.event?.triggerInteractionPopUp(at: object.coordinate)
            scene.player?.interactionStatus = .onExit
        }
    }
    
    /// When the player is on the coordinate of a blue crystal.
    private func playerOnBlueCrystal(_ first: CollisionManager.NodeBody,
                                     with second: CollisionManager.NodeBody) {
        guard let object = second.body.node as? PKObjectNode else { return }
        guard object.name == GameConfiguration.nodeKey.blueCrystal else { return }
        if manager.isColliding(first, with: second) {
            scene.core?.event?.triggerInteractionPopUp(at: object.coordinate)
            scene.player?.interactionStatus = .onBlueCrystal
        }
    }
}
