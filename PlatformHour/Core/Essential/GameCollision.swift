//
//  GameCollision.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import SpriteKit
import PlayfulKit

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
        
        // Projectile collision with objects
        projectileHit(
            CollisionManager.NodeBody(body: firstBody,
                                      bitmaskCategory: CollisionCategory.playerProjectile.rawValue),
            with: CollisionManager.NodeBody(body: secondBody,
                                            bitmaskCategory: CollisionCategory.object.rawValue)
        )
        
        playerTouchSphere(
            CollisionManager.NodeBody(body: firstBody, bitmaskCategory: CollisionCategory.player.rawValue),
            with: CollisionManager.NodeBody(body: secondBody, bitmaskCategory: CollisionCategory.object.rawValue)
        )
        
        playerTouchStatue(
            CollisionManager.NodeBody(body: firstBody, bitmaskCategory: CollisionCategory.player.rawValue),
            with: CollisionManager.NodeBody(body: secondBody, bitmaskCategory: CollisionCategory.object.rawValue)
        )
    }
    
    func projectileHit(_ first: CollisionManager.NodeBody, with second: CollisionManager.NodeBody) {
        guard let projectile = first.body.node as? PKObjectNode else { return }
        guard let object = second.body.node as? PKObjectNode else { return }
        if manager.isColliding(first, with: second) {
            collisionLogic.projectileHitObject(projectile, objectNode: object)
        }
    }
    
    func playerTouchSphere(_ first: CollisionManager.NodeBody, with second: CollisionManager.NodeBody) {
        guard let object = second.body.node as? PKObjectNode else { return }
        guard object.name == "Sphere" else { return }
        if manager.isColliding(first, with: second) {
            object.removeFromParent()
        }
    }
    
    func playerTouchStatue(_ first: CollisionManager.NodeBody, with second: CollisionManager.NodeBody) {
        guard let object = second.body.node as? PKObjectNode else { return }
        guard object.name == "Statue" else { return }
        if manager.isColliding(first, with: second) {
            scene.core?.environment?.showInteractionMessage()
        }
    }
}
