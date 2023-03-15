//
//  ActionLogic.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import SpriteKit
import PlayfulKit

public class ActionLogic {
    
    public init(scene: GameScene) {
        self.scene = scene
    }
    
    public enum Direction: String, CaseIterable {
        case none
        case up
        case down
        case right
        case left
    }
    
    public var scene: GameScene
    
    public var timer: Timer?
    public var direction: Direction = .none
    public var isJumping: Bool = false
    
    public var isProjectileTurningBack: Bool = false
    
    var isAnimating: Bool {
        guard let player = scene.player else { return false }
        return player.node.hasActions()
    }
    var isAttacking: Bool {
        scene.isExistingChildNode(named: GameApp.sceneConfigurationKey.playerProjectile)
    }
    
    // MARK: - Movements
    private func move(on direction: Direction, by amount: Int) {
        if !isAnimating {
            self.direction = direction
            changeOrientation(direction: self.direction)
            moveAnimation(by: amount)
            scene.player?.run()
            switchPlayerArrowDirection()
        }
    }
    func moveRight() {
        move(on: .right, by: 2)
    }
    func moveLeft() {
        move(on: .left, by: -2)
    }
    func moveAnimation(by amount: Int) {
        guard let player = scene.player else { return }
        guard let environment = scene.core?.environment else { return }
        
        let playerCoordinate = player.node.coordinate
        
        let destinationCoordinate = Coordinate(x: playerCoordinate.x,
                                               y: playerCoordinate.y + amount)
        
        guard let destinationPosition = environment.map.tilePosition(from: destinationCoordinate) else { return }
        
        let moveSequence = moveSequence(destinationPosition: destinationPosition,
                                        destinationCoordinate: destinationCoordinate, amount: amount)
        
        scene.player?.node.run(moveSequence)
    }
    
    func moveSequence(destinationPosition: CGPoint,
                      destinationCoordinate: Coordinate,
                      amount: Int) -> SKAction {
        guard let environment = scene.core?.environment else { return SKAction.empty() }
        let sequence = SKAction.sequence([
            SKAction.run {
                self.scene.core?.event?.dismissButtonPopUp()
                self.scene.core?.event?.dismissStatueRequirementPopUp()
            },
            SKAction.move(to: destinationPosition, duration: scene.player?.runDuration ?? 0),
            SKAction.run {
                self.scene.player?.advanceRoll()
                self.scene.player?.node.coordinate = destinationCoordinate
                self.scene.core?.sound.step()
                self.scene.player?.node.removeAllActions()
            }
        ])
        #warning("if can 2 and can't one, one. if can 2 and can one, two")
        let coordinate = Coordinate(x: destinationCoordinate.x, y: destinationCoordinate.y + (amount - 1))
        let coordinates = [destinationCoordinate, coordinate]
        return !environment.collisionCoordinates.contains(coordinates) ? sequence : SKAction.empty()
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
           let arrowNode = player.node.childNode(withName: GameApp.sceneConfigurationKey.playerArrow) as? SKSpriteNode {
            arrowNode.texture = SKTexture(imageNamed: player.orientation.arrow)
            arrowNode.texture?.filteringMode = .nearest
        }
    }
    
    // MARK: - Actions
    func attack() {
        if !isAttacking && !isAnimating {
            if let projectileNode = scene.core?.content?.projectileNode {
                scene.addChild(projectileNode)
                projectileAnimation(projectileNode)
            }
        }
    }
    func pause() {
        switch scene.core?.state.status {
        case .inGame:
            scene.core?.content?.pause()
            scene.core?.state.status = .inPause
            scene.core?.hud?.createPauseScreen()
        case .inPause:
            scene.core?.content?.unpause()
            scene.core?.state.status = .inGame
            scene.core?.hud?.removePauseScreen()
        case .none:
            ()
        }
    }
    
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
    
    func interact() {
        guard let player = scene.player else { return }
        guard !player.bag.isEmpty else { return }
        
        switch player.interactionStatus {
        case .none:
            ()
        case .onStatue:
            scene.core?.event?.giveItemToStatue()
        }
    }
    
    // MARK: - Projectiles
    
    func projectileFollowPlayer() {
        if let player = scene.player,
           let projectile = scene.childNode(withName: GameApp.sceneConfigurationKey.playerProjectile) {
            if isProjectileTurningBack {
                projectile.run(SKAction.follow(player.node, duration: player.attackSpeed))
                if projectile.contains(player.node.position) {
                    projectile.removeFromParent()
                    isProjectileTurningBack = false
                }
            }
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
}
