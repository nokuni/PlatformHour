//
//  CollisionLogic.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import SpriteKit

class CollisionLogic {
    
    init(scene: SKScene) {
        self.scene = scene
    }
    
    var scene: SKScene?
    
    func hitNumberBox(_ object: SKSpriteNode) {
        guard let scene = scene as? GameScene else { return }
        let startingPosition = object.position
        let destination = CGPoint(x: object.position.x, y: object.position.y + 50)
        let sequence = SKAction.sequence([
            SKAction.run { scene.logic?.lockDiceBox(object) },
            SKAction.move(to: destination, duration: 0.1),
            SKAction.move(to: startingPosition, duration: 0.1),
        ])
        object.run(sequence)
    }
    
    func landingOnground() {
        guard let scene = scene as? GameScene else { return }
        guard let controller = scene.controller else { return }
        
        scene.player.node.physicsBody?.velocity = .zero
        
        if controller.isJumping {
            scene.controller?.isJumping = false
            scene.controller?.virtual?.hasPressedAnyInput = false
            scene.animation?.circularSmoke(on: scene.player.node)
        }
    }
}
