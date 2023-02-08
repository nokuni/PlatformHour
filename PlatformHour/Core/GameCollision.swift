//
//  GameCollision.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import SpriteKit

final public class GameCollision {
    
    init(scene: SKScene) {
        self.scene = scene
        self.logic = CollisionLogic(scene: scene)
    }
    
    var scene: SKScene?
    var logic: CollisionLogic?
    
    let playerMask: UInt32 = 0x1 << 0
    let objectMask: UInt32 = 0x1 << 1
    let wallMask: UInt32 = 0x1 << 2
    
    struct NodeBody {
        let body: SKPhysicsBody
        let bitmaskCategory: UInt32
    }
    
    // Compare two bodies and return true if they are colliding, false if they are not.
    func isColliding(_ first: NodeBody, with second: NodeBody) -> Bool {
        first.body.categoryBitMask == first.bitmaskCategory && second.body.categoryBitMask == second.bitmaskCategory
    }
    
    func hitObject(_ first: NodeBody, with second: NodeBody) {
        guard let object = second.body.node as? SKSpriteNode else { return }
        if isColliding(first, with: second) {
            logic?.hitNumberBox(object)
        }
    }
    
    func landOnGround(_ first: NodeBody, with second: NodeBody) {
        if isColliding(first, with: second) {
            logic?.landingOnground()
        }
    }
}
