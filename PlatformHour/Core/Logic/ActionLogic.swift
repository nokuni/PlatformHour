//
//  ActionLogic.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import SpriteKit
import PlayfulKit

public class ActionLogic {
    
    public init(scene: GameScene,
                state: GameState,
                environment: GameEnvironment,
                content: GameContent) {
        self.scene = scene
        self.state = state
        self.environment = environment
        self.content = content
    }
    
    public enum Direction: String, CaseIterable {
        case none
        case up
        case down
        case right
        case left
    }
    
    public var scene: GameScene
    public var state: GameState
    public var environment: GameEnvironment
    public var content: GameContent
    
    public var timer: Timer?
    public var direction: Direction = .none
    public var isJumping: Bool = false
    
    public var isProjectileTurningBack: Bool = false
    
    var isAnimating: Bool {
        guard let player = scene.player else { return false }
        return player.node.hasActions()
    }
    var isAttacking: Bool {
        scene.isExistingChildNode(named: "Player Projectile")
    }
    
    // MARK: - Movements
    func moveRight() { move(on: .right, by: 1) }
    func moveLeft() { move(on: .left, by: -1) }
    func upAction() {
        if !isAttacking {
            scene.player?.orientation = .up
            switchPlayerArrowDirection()
        }
    }
    func downAction() {
        if !isAttacking {
            scene.player?.orientation = .down
            switchPlayerArrowDirection()
        }
    }
    
    func changeOrientation(direction: Direction) {
        switch direction {
        case .right:
            scene.player?.orientation = .right
        case .left:
            scene.player?.orientation = .left
        case .up:
            scene.player?.orientation = .up
        case .down:
            scene.player?.orientation = .down
        case .none:
            ()
        }
    }
    
    // MARK: - Others
    func switchPlayerArrowDirection() {
        if let player = scene.player,
           let arrowNode = player.node.childNode(withName: "Player Arrow") as? SKSpriteNode {
            arrowNode.texture = SKTexture(imageNamed: player.orientation.arrow)
            arrowNode.texture?.filteringMode = .nearest
        }
    }
    func dismissInteractionMessage() {
        guard let interactionNode = scene.childNode(withName: "Interaction") else { return }
        interactionNode.removeFromParent()
    }
    
    // MARK: - Actions
    func jump() {
        // Configure jump
    }
    func attack() {
        if !isAttacking && !isAnimating {
            let projectileNode = content.projectileNode
            scene.addChild(projectileNode)
            projectileAnimation(projectileNode)
        }
    }
    func move(on direction: Direction, by amount: Int) {
        if !isAnimating {
            self.direction = direction
            changeOrientation(direction: self.direction)
            moveAnimation(by: amount)
            scene.player?.run()
            scene.player?.advanceRoll()
            switchPlayerArrowDirection()
        }
    }
    func pause() {
        switch state.status {
        case .inGame:
            scene.core?.content?.pause()
            scene.core?.state?.status = .inPause
            scene.core?.hud?.createPauseScreen()
        case .inPause:
            scene.core?.content?.unpause()
            scene.core?.state?.status = .inGame
            scene.core?.hud?.removePauseScreen()
        }
    }
    
    // MARK: - PROJECTILES
    
    func projectileFollowPlayer() {
        if let player = scene.player,
           let projectile = scene.childNode(withName: "Player Projectile") {
            if isProjectileTurningBack {
                projectile.run(SKAction.follow(player.node, duration: player.attackSpeed))
                if projectile.contains(player.node.position) {
                    projectile.removeFromParent()
                    isProjectileTurningBack = false
                }
            }
        }
    }
    
    // MARK: - Animations
    func moveAnimation(by amount: Int) {
        guard let player = scene.player else { return }
        let playerCoordinate = player.node.coordinate
        
        let destinationCoordinate = Coordinate(x: playerCoordinate.x,
                                               y: playerCoordinate.y + amount)
        
        guard let destinationPosition = environment.map.tilePosition(from: destinationCoordinate) else { return }
        
        let moveSequence = SKAction.sequence([
            SKAction.run {
                self.dismissInteractionMessage()
            },
            SKAction.move(to: destinationPosition, duration: 0.15),
            SKAction.run {
                self.scene.player?.node.coordinate = destinationCoordinate
                self.scene.core?.sound?.step()
                self.scene.player?.node.physicsBody?.velocity = .zero
                self.scene.player?.node.removeAllActions()
            }
        ])
        let cancelSequence = SKAction.sequence([
            SKAction.wait(forDuration: 0.1),
            SKAction.run { self.scene.player?.node.physicsBody?.velocity = .zero }
        ])
        
        if environment.coordinates.contains(destinationCoordinate) {
            scene.player?.node.run(cancelSequence)
        } else {
            scene.player?.node.run(moveSequence)
        }
    }
    func projectileAnimation(_ projectileNode: PKObjectNode) {
        guard let player = scene.player else { return }
        let distanceAmount = CGFloat(player.range)
        var xDistance: CGFloat = 0
        var yDistance: CGFloat = 0
        
        switch player.orientation {
        case .right: xDistance = player.node.size.width * distanceAmount
        case .left: xDistance = -player.node.size.width * distanceAmount
        case .up: yDistance = player.node.size.height * distanceAmount
        case .down: yDistance = -player.node.size.height * distanceAmount
        }
        
        let destination = CGPoint(x: player.node.position.x + xDistance,
                                  y: player.node.position.y + yDistance)
        
        let sequence = SKAction.sequence([
            SKAction.move(to: destination, duration: player.attackSpeed),
            SKAction.run { self.isProjectileTurningBack = true }
        ])
        
        projectileNode.run(sequence)
    }
    func stopMovement() {
        timer?.invalidate()
        direction = .none
        scene.player?.stop()
    }
}
