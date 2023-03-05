//
//  GameCollision.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import SpriteKit
import PlayfulKit

final public class GameCollision {
    
    init(scene: GameScene,
         animation: GameAnimation,
         environment: GameEnvironment,
         logic: GameLogic) {
        self.scene = scene
        self.animation = animation
        self.environment = environment
        self.collisionLogic = CollisionLogic(scene: scene, animation: animation, logic: logic)
    }
    
    var scene: GameScene
    var animation: GameAnimation
    var environment: GameEnvironment
    var collisionLogic: CollisionLogic
    
    struct NodeBody {
        let body: SKPhysicsBody
        let bitmaskCategory: UInt32
    }
    
    func all(firstBody: SKPhysicsBody, secondBody: SKPhysicsBody) {
        
        // Projectile collision with structures
        projectileHit(
            GameCollision.NodeBody(body: firstBody,
                                   bitmaskCategory: CollisionCategory.playerProjectile.rawValue),
            with: GameCollision.NodeBody(body: secondBody,
                                         bitmaskCategory: CollisionCategory.structure.rawValue)
        )
        
        // Projectile collision with objects
        projectileHit(
            GameCollision.NodeBody(body: firstBody,
                                   bitmaskCategory: CollisionCategory.playerProjectile.rawValue),
            with: GameCollision.NodeBody(body: secondBody,
                                         bitmaskCategory: CollisionCategory.object.rawValue)
        )
        
        // Player collision with structure
        landOnGround(
            GameCollision.NodeBody(body: firstBody, bitmaskCategory: CollisionCategory.player.rawValue),
            with: GameCollision.NodeBody(body: secondBody, bitmaskCategory: CollisionCategory.structure.rawValue)
        )
    }
    
    /// Compare two physics bodies and return true if they are colliding, false if they are not.
    func isColliding(_ first: NodeBody, with second: NodeBody) -> Bool {
        return first.body.categoryBitMask == first.bitmaskCategory && second.body.categoryBitMask == second.bitmaskCategory
    }
    
    func projectileHit(_ first: NodeBody, with second: NodeBody) {
        guard let projectile = first.body.node as? PKObjectNode else { return }
        guard let object = second.body.node as? PKObjectNode else { return }
        if isColliding(first, with: second) {
            collisionLogic.projectileHitObject(projectile, objectNode: object)
        }
    }
    
    func landOnGround(_ first: NodeBody, with second: NodeBody) {
        if isColliding(first, with: second) {
            collisionLogic.landingOnground()
        }
    }
}
