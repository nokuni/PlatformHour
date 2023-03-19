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
    
    var isAnimating: Bool {
        guard let player = scene.player else { return false }
        return player.node.hasActions()
    }
    var isAttacking: Bool {
        scene.isExistingChildNode(named: GameConfiguration.sceneConfigurationKey.playerProjectile)
    }
    
    var canAct: Bool {
        scene.isUserInteractionEnabled
    }
    
    // MARK: - Movements
    private func move(on direction: Direction, by amount: Int) {
        guard let player = scene.player else { return }
        guard !isAnimating else { return }
        guard !player.isJumping else { return }
        guard canAct else { return }
        
        self.direction = direction
        changeOrientation(direction: self.direction)
        moveAnimation(by: amount)
        scene.player?.advanceRoll()
        scene.player?.run()
        switchPlayerArrowDirection()
    }
    func moveRight() {
        guard let player = scene.player else { return }
        guard let environment = scene.core?.environment else { return }
        let movementSpeed = GameConfiguration.playerConfiguration.movementSpeed
        
        guard let maxCameraPosition = environment.map.tilePosition(from: Coordinate(x: 13, y: 8)) else { return }

        let limit = -(GameConfiguration.worldConfiguration.tileSize.width * 34)
        
        if let background = scene.childNode(withName: "Background") {
            let destinationPosition = CGPoint(x: background.position.x + (-GameConfiguration.worldConfiguration.tileSize.width), y: 0)
            let action = SKAction.move(to: destinationPosition, duration: player.runDuration)
            if background.position.x > limit && player.node.position.x > maxCameraPosition.x {
                background.run(action)
            }
        }
        
        move(on: .right, by: movementSpeed)
    }
    func moveLeft() {
        guard let player = scene.player else { return }
        guard let environment = scene.core?.environment else { return }
        let movementSpeed = -GameConfiguration.playerConfiguration.movementSpeed
        
        guard let maxCameraPosition = environment.map.tilePosition(from: Coordinate(x: 13, y: 44)) else { return }

        if let background = scene.childNode(withName: "Background") {
            let destinationPosition = CGPoint(x: background.position.x + GameConfiguration.worldConfiguration.tileSize.width, y: 0)
            let action = SKAction.move(to: destinationPosition, duration: player.runDuration)
            if background.position.x < 0 && player.node.position.x < maxCameraPosition.x {
                background.run(action)
            }
        }
        
        move(on: .left, by: movementSpeed)
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
        guard let player = scene.player else { return SKAction.empty() }
        guard let environment = scene.core?.environment else { return SKAction.empty() }
        let sequence = SKAction.sequence([
            SKAction.move(to: destinationPosition, duration: player.runDuration),
            SKAction.run {
                self.scene.core?.sound.step()
                self.scene.player?.node.removeAllActions()
            }
        ])
        return !environment.collisionCoordinates.contains(destinationCoordinate) ? sequence : SKAction.empty()
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
           let arrowNode = player.node.childNode(withName: GameConfiguration.sceneConfigurationKey.playerArrow) as? SKSpriteNode {
            arrowNode.texture = SKTexture(imageNamed: player.orientation.arrow)
            arrowNode.texture?.filteringMode = .nearest
        }
    }
    
    // MARK: - Actions
    func jump() {
        guard let player = scene.player else { return }
        guard !player.isJumping else { return }
        guard !isAnimating else { return }
        let jumpAmount = CGFloat(player.currentRoll.rawValue)
        let moveUpValue = GameConfiguration.worldConfiguration.tileSize.height
        let moveUpDestination = CGPoint(x: player.node.position.x,
                                        y: player.node.position.y + moveUpValue)
        let array = stride(from: 0, to: jumpAmount, by: 1)
        let destinations = array.map {
            CGPoint(x: moveUpDestination.x, y: moveUpDestination.y + (moveUpValue * $0))
        }
        var actions = destinations.map {
            SKAction.sequence([
                SKAction.move(to: $0, duration: 0.1),
                SKAction.wait(forDuration: 0.2)
            ])
        }
        actions.append(SKAction.run { self.scene.core?.content?.addJumpTimerBar(on: player.node) })
        player.isJumping = true
        let jumpSequence = SKAction.sequence(actions)
        player.node.run(jumpSequence)
    }
    func attack() {
        guard !isAttacking else { return }
        guard !isAnimating else { return }
        guard canAct else { return }
        
        if let projectileNode = scene.core?.content?.projectileNode {
            scene.addChild(projectileNode)
            throwProjectile(projectileNode)
        }
    }
    func pause() {
        guard canAct else { return }
        
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
        guard canAct else { return }
        guard let player = scene.player else { return }
        guard let environment = scene.core?.environment else { return }
        let playerCoordinate = player.node.coordinate
        
        let destinationCoordinate = Coordinate(x: playerCoordinate.x - 1,
                                               y: playerCoordinate.y)
        
        guard let destinationPosition = environment.map.tilePosition(from: destinationCoordinate) else { return }
        
        let action = SKAction.move(to: destinationPosition, duration: player.runDuration)
        scene.player?.node.run(action)
//        scene.player?.orientation = .up
//        switchPlayerArrowDirection()
    }
    func downAction() {
        guard canAct else { return }
        guard let player = scene.player else { return }
        guard let environment = scene.core?.environment else { return }
        let playerCoordinate = player.node.coordinate
        
        let destinationCoordinate = Coordinate(x: playerCoordinate.x + 1,
                                               y: playerCoordinate.y)
        
        guard let destinationPosition = environment.map.tilePosition(from: destinationCoordinate) else { return }
        let action = SKAction.move(to: destinationPosition, duration: player.runDuration)
        scene.player?.node.run(action)
//        scene.player?.orientation = .down
//        switchPlayerArrowDirection()
    }
    
    func interact() {
        guard let player = scene.player else { return }
        guard !player.bag.isEmpty else { return }
        guard canAct else { return }
        
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
           let projectile = scene.childNode(withName: GameConfiguration.sceneConfigurationKey.playerProjectile) {
            if player.isProjectileTurningBack {
                projectile.run(SKAction.follow(player.node, duration: player.attackSpeed))
                if projectile.contains(player.node.position) {
                    projectile.removeFromParent()
                    player.isProjectileTurningBack = false
                }
            }
        }
    }
    
    func throwProjectile(_ projectileNode: PKObjectNode) {
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
            SKAction.run {
                player.isProjectileTurningBack = true
            }
        ])
        
        projectileNode.run(sequence)
    }
}
