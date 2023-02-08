//
//  ActionLogic.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import SpriteKit

class ActionLogic {
    
    init(scene: SKScene, controller: GameControllerManager) {
        self.scene = scene
        self.controller = controller
    }
    
    var scene: SKScene?
    var controller: GameControllerManager
    
    var verticalVelocity: CGFloat {
        return UIDevice.isOnPhone ? CGSize.screen.height * 0.3 : CGSize.screen.height * 0.35
    }
    
    func horizontal(right: Float, left: Float) {
        guard let scene = scene as? GameScene else { return }
        
        let isLeft = left == 1
        let isRight = right == 1
        
        controller.timer?.invalidate()
        controller.direction = .none
        
        switch true {
        case isLeft:
            hold(on: .left, by: -(scene.player.node.size.width))
        case isRight:
            hold(on: .right, by: scene.player.node.size.width)
        default:
            controller.direction = .none
            scene.player.stop()
        }
    }
    
    func hold(on direction: GameControllerManager.Direction, by amount: CGFloat) {
        guard let scene = scene as? GameScene else { return }
        if !controller.isMoving {
            controller.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { timer in
                if scene.player.node.physicsBody?.velocity == .zero && !scene.player.node.hasActions() {
                    self.controller.isMoving = true
                    self.controller.direction = direction
                    self.moveHorizontally(by: amount)
                    scene.player.run()
                    scene.player.advanceRoll()
                }
            })
            controller.timer?.fire()
        }
    }
    
    func jump() {
        guard let scene = scene as? GameScene else { return }
        if !controller.isMoving && scene.player.node.physicsBody?.velocity == .zero {
            controller.isJumping = true
            let verticalValue: CGFloat = verticalVelocity
            vertical(by: verticalValue)
        }
    }
    
    func moveHorizontally(by amount: CGFloat) {
        guard let scene = scene as? GameScene else { return }
        guard let dimension = scene.dimension else { return }
        let destination = CGPoint(x: scene.player.node.position.x + amount,
                                  y: scene.player.node.position.y)
        
        let moveSequence = SKAction.sequence([
            SKAction.move(to: destination, duration: 0.1),
            SKAction.run {
                scene.sound?.step()
                self.controller.isMoving = false
            }
        ])
        let cancelSequence = SKAction.sequence([
            SKAction.wait(forDuration: 0.1),
            SKAction.run {
                self.controller.isMoving = false
                if amount > 0 { scene.logic?.exitLevel() }
            }
        ])
        
        let canMoveOnLeft = destination.x >= dimension.leftLimit && amount < 0
        let canMoveOnRight = destination.x <= dimension.rightLimit && amount > 0
        
        switch true {
        case canMoveOnLeft:
            scene.player.node.run(moveSequence)
        case canMoveOnRight:
            scene.player.node.run(moveSequence)
        default:
            scene.player.node.run(cancelSequence)
        }
    }
    
    func teleport() {
        guard let scene = scene as? GameScene else { return }
        
        let currentRoll = CGFloat(scene.player.currentRoll.rawValue)
        let teleportationAmount = scene.player.node.size.width * currentRoll
        let destination = CGPoint(x: scene.player.node.position.x + teleportationAmount, y: scene.player.node.position.y)
        let sequence = SKAction.sequence([
            SKAction.move(to: destination, duration: 0)
        ])
        scene.player.node.run(sequence)
    }
    
    func pause() {
        guard let scene = scene as? GameScene else { return }
        guard let state = scene.state else { return }
        switch state.status {
        case .inGame:
            scene.content?.pause()
            scene.state?.status = .inPause
            scene.hud?.createPauseScreen()
        case .inPause:
            scene.content?.unpause()
            scene.state?.status = .inGame
            scene.hud?.removePauseScreen()
        }
    }
    
    func vertical(by amount: CGFloat) {
        guard let scene = scene as? GameScene else { return }
        scene.player.node.physicsBody?.applyImpulse(CGVector(dx: 0, dy: amount))
    }
    
    func stopMovement() {
        guard let scene = scene as? GameScene else { return }
        controller.timer?.invalidate()
        controller.direction = .none
        scene.player.stop()
        controller.virtual?.hasPressedAnyInput = false
    }
}
