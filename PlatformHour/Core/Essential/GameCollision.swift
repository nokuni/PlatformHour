//
//  GameCollision.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import SpriteKit
import PlayfulKit
import Utility_Toolbox

final public class GameCollision {
    
    public init(scene: GameScene) {
        self.scene = scene
        self.collisionLogic = CollisionLogic(scene: scene)
    }
    
    public var scene: GameScene
    public var collisionLogic: CollisionLogic
    
    public var manager = CollisionManager()
    
    func all(firstBody: SKPhysicsBody, secondBody: SKPhysicsBody) {
        
        // Projectile collision with structures
        projectileHit(
            CollisionManager.NodeBody(body: firstBody,
                                      bitmaskCategory: CollisionCategory.playerProjectile.rawValue),
            with: CollisionManager.NodeBody(body: secondBody,
                                            bitmaskCategory: CollisionCategory.structure.rawValue)
        )
        
        // Player projectile collision with objects
        projectileHit(
            CollisionManager.NodeBody(body: firstBody,
                                      bitmaskCategory: CollisionCategory.playerProjectile.rawValue),
            with: CollisionManager.NodeBody(body: secondBody,
                                            bitmaskCategory: CollisionCategory.object.rawValue)
        )
        
        // Player projectile collision structure
        projectileStructure(
            CollisionManager.NodeBody(body: firstBody,
                                      bitmaskCategory: CollisionCategory.playerProjectile.rawValue),
            with: CollisionManager.NodeBody(body: secondBody,
                                            bitmaskCategory: CollisionCategory.structure.rawValue)
        )
        
        // Player collision with object item
        playerTouchItem(
            CollisionManager.NodeBody(body: firstBody, bitmaskCategory: CollisionCategory.player.rawValue),
            with: CollisionManager.NodeBody(body: secondBody, bitmaskCategory: CollisionCategory.item.rawValue)
        )
        
        // Player collision with object exit
        playerIsOnExit(
            CollisionManager.NodeBody(body: firstBody, bitmaskCategory: CollisionCategory.player.rawValue),
            with: CollisionManager.NodeBody(body: secondBody, bitmaskCategory: CollisionCategory.npc.rawValue)
        )
        
        // Player collision with structure
        playerTouchGround(
            CollisionManager.NodeBody(body: firstBody, bitmaskCategory: CollisionCategory.player.rawValue),
            with: CollisionManager.NodeBody(body: secondBody, bitmaskCategory: CollisionCategory.structure.rawValue)
        )
        
        // Enemy collision with player
        enemyTouchPlayer(
            CollisionManager.NodeBody(body: firstBody, bitmaskCategory: CollisionCategory.player.rawValue),
            with: CollisionManager.NodeBody(body: secondBody, bitmaskCategory: CollisionCategory.enemy.rawValue)
        )
        
        // Player collision with enemy
        playerTouchEnemy(
            CollisionManager.NodeBody(body: firstBody, bitmaskCategory: CollisionCategory.player.rawValue),
            with: CollisionManager.NodeBody(body: secondBody, bitmaskCategory: CollisionCategory.enemy.rawValue)
        )
    }
    
    func projectileHit(_ first: CollisionManager.NodeBody, with second: CollisionManager.NodeBody) {
        guard let projectile = first.body.node as? PKObjectNode else { return }
        guard let object = second.body.node as? PKObjectNode else { return }
        if manager.isColliding(first, with: second) {
            collisionLogic.projectileHitObject(projectile, objectNode: object)
        }
    }
    
    func projectileStructure(_ first: CollisionManager.NodeBody, with second: CollisionManager.NodeBody) {
        guard let projectile = first.body.node as? PKObjectNode else { return }
        if manager.isColliding(first, with: second) {
            projectile.removeAllActions()
            scene.player?.isProjectileTurningBack = true
        }
    }
    
    func playerTouchItem(_ first: CollisionManager.NodeBody, with second: CollisionManager.NodeBody) {
        guard let object = second.body.node as? PKObjectNode else { return }
        guard let itemName = object.name else { return }
        guard let allItemNames = GameItem.allNames else { return }
        guard allItemNames.contains(itemName) else { return }
        if manager.isColliding(first, with: second) {
            collisionLogic.pickUpItem(object: object, name: itemName)
        }
    }
    
    func playerIsOnExit(_ first: CollisionManager.NodeBody, with second: CollisionManager.NodeBody) {
        guard let object = second.body.node as? PKObjectNode else { return }
        guard object.name == GameConfiguration.sceneConfigurationKey.exit else { return }
        if manager.isColliding(first, with: second) {
            scene.core?.environment?.showStatueInteractionPopUp()
            scene.player?.interactionStatus = .onExit
        }
    }
    
    func playerTouchGround(_ first: CollisionManager.NodeBody, with second: CollisionManager.NodeBody) {
        if manager.isColliding(first, with: second) {
            collisionLogic.landOnGround()
        }
    }
    
    func enemyTouchPlayer(_ first: CollisionManager.NodeBody, with second: CollisionManager.NodeBody) {
        guard let player = scene.player else { return }
        guard let enemyNode = second.body.node as? PKObjectNode else { return }
        if !player.logic.isIntangible && manager.isColliding(first, with: second) {
            collisionLogic.enemyHitPlayer(enemyNode)
        }
    }
    
    func playerTouchEnemy(_ first: CollisionManager.NodeBody, with second: CollisionManager.NodeBody) {
        guard let enemyNode = second.body.node as? PKObjectNode else { return }
        if manager.isColliding(first, with: second) {
            collisionLogic.playerDropOnEnemy(enemyNode)
        }
    }
}
