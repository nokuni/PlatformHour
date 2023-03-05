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
    
    var isMoving: Bool {
        scene.player.node.physicsBody?.velocity != .zero
    }
    var isAnimating: Bool {
        scene.player.node.hasActions()
    }
    var isAttacking: Bool {
        scene.isExistingChildNode(named: "Player Projectile")
    }
    
    // MARK: - Movements
    func moveRight() { move(on: .right, by: 1) }
    func moveLeft() { move(on: .left, by: -1) }
    
    func changeOrientation(direction: Direction) {
        switch direction {
        case .right:
            scene.player.orientation = .right
        case .left:
            scene.player.orientation = .left
        case .up:
            scene.player.orientation = .up
        case .down:
            scene.player.orientation = .down
        case .none:
            ()
        }
    }
    
    // MARK: - Others
    func switchPlayerArrowDirection() {
        if let arrowNode = scene.player.node.childNode(withName: "Player Arrow") as? SKSpriteNode {
            arrowNode.texture = SKTexture(imageNamed: scene.player.orientation.arrow)
            arrowNode.texture?.filteringMode = .nearest
        }
    }
    
    // MARK: - Actions
    func jump() {
        // Configure jump
    }
    func attack() {
        if !isMoving && !isAttacking {
            print("Projectile created")
            let projectileNode = content.projectileNode
            scene.addChild(projectileNode)
            projectileAnimation(projectileNode)
        }
    }
    func move(on direction: Direction, by amount: Int) {
        if !isMoving && !isAnimating && !isAttacking {
            self.direction = direction
            changeOrientation(direction: self.direction)
            moveAnimation(by: amount)
            scene.player.run()
            scene.player.advanceRoll()
            switchPlayerArrowDirection()
        }
    }
    func pause() {
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
    
    // MARK: - Animations
    func moveAnimation(by amount: Int) {
        let playerCoordinate = scene.player.node.coordinate
        
        let destinationCoordinate = Coordinate(x: playerCoordinate.x,
                                               y: playerCoordinate.y + amount)
        
        guard let destinationPosition = environment.map.tilePosition(from: destinationCoordinate) else { return }
        
        let moveSequence = SKAction.sequence([
            SKAction.move(to: destinationPosition, duration: 0.1),
            SKAction.run {
                self.scene.player.node.coordinate = destinationCoordinate
                self.scene.sound?.step()
                self.scene.player.node.physicsBody?.velocity = .zero
                if let exitCoordinate = self.scene.game?.exitCoordinate,
                   let exitPosition = self.environment.map.tilePosition(from: exitCoordinate) {
                    if (destinationPosition == exitPosition) && self.environment.isExitOpen {
                        self.scene.game?.goToNextLevel()
                        let newScene = GameScene()
                        let transition = SKTransition.fade(withDuration: 2)
                        self.scene.view?.presentScene(newScene, transition: transition)
                    }
                }
            }
        ])
        let cancelSequence = SKAction.sequence([
            SKAction.wait(forDuration: 0.1),
            SKAction.run { self.scene.player.node.physicsBody?.velocity = .zero }
        ])
        
        if environment.coordinates.contains(destinationCoordinate) {
            scene.player.node.run(cancelSequence)
        } else {
            scene.player.node.run(moveSequence)
        }
    }
    func projectileAnimation(_ projectileNode: PKObjectNode) {
        
        let distanceAmount = CGFloat(scene.player.range)
        var xDistance: CGFloat = 0
        var yDistance: CGFloat = 0
        
        switch scene.player.orientation {
        case .right: xDistance = scene.player.node.size.width * distanceAmount
        case .left: xDistance = -scene.player.node.size.width * distanceAmount
        case .up: yDistance = scene.player.node.size.height * distanceAmount
        case .down: yDistance = -scene.player.node.size.height * distanceAmount
        }
        
        let destination = CGPoint(x: scene.player.node.position.x + xDistance,
                                  y: scene.player.node.position.y + yDistance)
        
        let sequence = SKAction.sequence([
            SKAction.move(to: destination, duration: scene.player.attackSpeed),
            SKAction.move(to: scene.player.node.position, duration: scene.player.attackSpeed),
            SKAction.removeFromParent()
        ])
        
        
        projectileNode.run(sequence)
    }
    func stopMovement() {
        timer?.invalidate()
        direction = .none
        scene.player.stop()
    }
}
