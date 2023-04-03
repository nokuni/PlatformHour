//
//  GameLogic.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 05/02/23.
//

import SpriteKit
import PlayfulKit
import Utility_Toolbox

public final class GameLogic {
    
    public init(scene: GameScene, environment: GameEnvironment) {
        self.scene = scene
        self.environment = environment
    }
    
    public var scene: GameScene
    public var environment: GameEnvironment
    
    public func damageObject(_ objectNode: PKObjectNode, with projectileNode: PKObjectNode) {
        guard objectNode.logic.isDestructible else { return }
        objectNode.logic.healthLost += projectileNode.logic.damage
        damage(objectNode)
    }
    
    public func damagePlayer(with enemyNode: PKObjectNode) {
        guard let player = scene.player else { return }
        player.node.logic.healthLost += enemyNode.logic.damage
        playerDestroy()
    }
    
//    public func updatePlayerHealth() {
//        guard let dice = scene.player else { return }
//        guard let healthBar = dice.node.childNode(withName: "Health Bar") else { return }
//        healthBar.removeFromParent()
//        scene.core?.content?.addHealthBar(amount: dice.currentBarHealth,
//                                          node: dice.node,
//                                          widthTailoring: (GameConfiguration.worldConfiguration.tileSize.width / 16) * 4)
//    }
    
    private func isDestroyed(_ objectNode: PKObjectNode) -> Bool {
        objectNode.logic.healthLost >= objectNode.logic.health
    }
    
    public func instantDestroy(_ objectNode: PKObjectNode) {
        objectNode.logic.healthLost = objectNode.logic.health
        if isDestroyed(objectNode) {
            objectNode.physicsBody?.categoryBitMask = .zero
            objectNode.physicsBody?.contactTestBitMask = .zero
            objectNode.physicsBody?.collisionBitMask = .zero
            scene.core?.animation?.destroyThenAnimate(scene: scene,
                                                      node: objectNode,
                                                      timeInterval: 0.1)
        }
    }
    
    private func playerDestroy() {
        guard let player = scene.player else { return }
        if isDestroyed(player.node) {
            player.death(scene: scene)
            scene.core?.animation?.transitionEffect(effect: SKAction.fadeIn(withDuration: 2),
                                                    isVisible: false,
                                                    scene: scene) {
                self.scene.core?.event?.restartLevel()
            }
        }
    }
    
    private func destroy(_ objectNode: PKObjectNode) {
        if isDestroyed(objectNode) {
            objectNode.physicsBody?.categoryBitMask = .zero
            objectNode.physicsBody?.contactTestBitMask = .zero
            objectNode.physicsBody?.collisionBitMask = .zero
            scene.core?.animation?.destroy(node: objectNode,
                                           filteringMode: .nearest) {
                //                if let item = objectNode.drops.first as? GameItem {
                //                    self.scene.core?.content?.dropItem(item, at: objectNode.coordinate)
                //                }
            }
        }
    }
    
    private func hit(_ objectNode: PKObjectNode) {
        scene.core?.animation?.hit(node: objectNode,
                                   filteringMode: .nearest)
    }
    
    private func damage(_ objectNode: PKObjectNode) {
        hit(objectNode)
        destroy(objectNode)
    }
    
    private func dropDestroyCube(coordinate: Coordinate) {
        guard let player = scene.player else { return }
        if let cube = environment.map.objects.first(where: {
            guard let name = $0.name else { return false }
            let isCube = name.contains("Cube")
            let isRightCube = name.extractedNumber == player.currentRoll.rawValue
            let isRightCoordinate = $0.coordinate == coordinate
            return isCube && isRightCube && isRightCoordinate
        }) {
            instantDestroy(cube)
        }
    }
    
    // Drop
    private func dropCoordinate(object: PKObjectNode) -> Coordinate {
        
        let objectCoordinate = object.coordinate
        
        var destinationCoordinate = Coordinate(x: objectCoordinate.x + 1,
                                               y: objectCoordinate.y)
        
        repeat {
            destinationCoordinate.x += 1
        } while !environment.collisionCoordinates.contains(destinationCoordinate) && destinationCoordinate.x <= GameConfiguration.worldConfiguration.xDeathBoundary
        
        destinationCoordinate.x -= 1
        
        return destinationCoordinate
    }
    
    private func dropPosition(object: PKObjectNode) -> CGPoint {
        let coordinate = dropCoordinate(object: object)
        guard let position = environment.map.tilePosition(from: coordinate) else { return .zero }
        
        return position
    }
    private func dropAction(object: PKObjectNode, speed: CGFloat) -> SKAction {
        let coordinate = dropCoordinate(object: object)
        let position = dropPosition(object: object)
        let moveAction = SKAction.move(from: object.position, to: position, at: speed)
        let action = !environment.isCollidingWithObject(at: coordinate) ? moveAction : SKAction.empty()
        
        return action
    }
    
    private var playerLandAnimation: SKAction {
        guard let player = scene.player else { return SKAction.empty() }
        let action = SKAction.run {
            self.scene.player?.currentRoll = .one
            self.scene.player?.resetToOne()
            self.scene.core?.animation?.circularSmoke(on: player.node)
            self.scene.core?.animation?.shakeScreen(scene: self.scene)
            self.scene.core?.sound.land()
        }
        return action
    }
    private var playerLandCompletionAction: SKAction {
        let action = SKAction.run {
            self.scene.player?.isJumping = false
            self.scene.player?.state = .normal
            self.enableControls()
        }
        return action
    }
    
    public func dropPlayer() {
        guard let player = scene.player else { return }
        player.node.removeAllActions()
        let drop = SKAction.sequence([
            dropAction(object: player.node, speed: 1000),
            playerLandAnimation,
            SKAction.wait(forDuration: 0.5),
            playerLandCompletionAction
        ])
        scene.player?.node.run(drop)
    }
    public func dropTrap(trapObject: PKObjectNode) {
        guard let game = scene.game else { return }
        guard let trapName = trapObject.name else { return }
        guard let id = trapName.extractedNumber else { return }
        guard let leveltrap = GameLevel.get(game.levelIndex)?.traps.first(where: {
            $0.id == String(id)
        }) else { return }
        let drop = SKAction.sequence([
            dropAction(object: trapObject, speed: 500),
            SKAction.run {
                self.scene.core?.animation?.destroyThenAnimate(scene: self.scene, node: trapObject, timeInterval: 0.1) {
                    self.scene.core?.content?.createTrap(leveltrap)
                }
            }
        ])
        trapObject.run(drop)
    }
    
    // Action Sequence
    private var actionSequenceAction: [SKAction] {
        guard let player = scene.player else { return [] }
        
        var currentCoordinate = player.node.coordinate
        var coordinates: [Coordinate] = []
        
        for action in player.actions {
            currentCoordinate.x += action.value.x
            currentCoordinate.y += action.value.y
            guard !environment.collisionCoordinates.contains(currentCoordinate) else { break }
            coordinates.append(currentCoordinate)
        }
        
        let positions = coordinates.compactMap { environment.map.tilePosition(from: $0) }
        
        let moves = positions.map {
            SKAction.move(to: $0, duration: 0.2)
        }
        
        return moves
    }
    public func endSequenceAction() {
        guard let player = scene.player else { return }
        player.actions.removeAll()
        self.scene.core?.hud?.removeDiceActions()
    }
    
    public func resolveActionSequence() {
        guard let player = scene.player else { return }
        if player.actions.count == player.currentRoll.rawValue {
            let gravityEffect = player.node.childNode(withName: GameConfiguration.sceneConfigurationKey.gravityEffect)
            gravityEffect?.removeFromParent()
            disableControls()
            performActionSequence()
        }
    }
    public func performActionSequence() {
        guard let player = scene.player else { return }
        
        var actions = actionSequenceAction
        actions.append(SKAction.run {
            self.endSequenceAction()
            self.dropPlayer()
        })
        
        let sequence = SKAction.sequence(actions)
        
        player.node.run(sequence)
    }
    
    // Projectiles
    func projectileFollowPlayer() {
        guard let player = scene.player else { return }
        guard let projectile = scene.childNode(withName: GameConfiguration.sceneConfigurationKey.playerProjectile) else {
            return
        }
        
        if player.isProjectileTurningBack {
            projectile.run(SKAction.follow(player.node, duration: player.attackSpeed))
            if projectile.contains(player.node.position) {
                projectile.removeFromParent()
                player.isProjectileTurningBack = false
            }
        }
    }
    
    // Controls
    public func disableControls() {
        scene.game?.controller?.manager?.action = nil
        scene.isUserInteractionEnabled = false
    }
    public func enableControls() {
        scene.game?.controller?.setupActions()
        scene.isUserInteractionEnabled = true
    }
}
