//
//  GameLogic.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 05/02/23.
//

import SpriteKit
import PlayfulKit
import UtilityToolbox

final class GameLogic {
    
    init(scene: GameScene, environment: GameEnvironment) {
        self.scene = scene
        self.environment = environment
    }
    
    var scene: GameScene
    var environment: GameEnvironment
    
    // Projectiles
    func projectileFollowPlayer() {
        guard let player = scene.player else { return }
        guard let projectile = scene.childNode(withName: GameConfiguration.nodeKey.playerProjectile) else {
            return
        }
        
        if player.state.hasProjectileTurningBack {
            projectile.run(SKAction.follow(player.node, duration: player.stats.attackSpeed))
            if projectile.contains(player.node.position) {
                projectile.removeFromParent()
                player.state.hasProjectileTurningBack = false
            }
        }
    }
}

// MARK: - Player Action Sequence

extension GameLogic {
    
    /// Returns the sequence moves.
    private func sequenceMoves(coordinates: [Coordinate]) -> [SKAction] {
        guard let player = scene.player else { return [] }
        let positions = coordinates.compactMap { environment.map.tilePosition(from: $0) }
        let moves = positions.map {
            SKAction.sequence([
                SKAction.move(to: $0, duration: 0.2),
                SKAction.run { [weak self] in
                    player.rollUp()
                    player.updateDiceSprite()
                    player.consumeEnergy(amount: 1)
                    self?.scene.core?.hud?.updateEnergy()
                }
            ])
        }
        return moves
    }
    
    /// Returns the sequence of action the player has to perform.
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
        
        let moves = sequenceMoves(coordinates: coordinates)
        
        return moves
    }
    
    func checkKeyDice() {
        
    }
    
    /// Resolve the perform of the sequence of actions.
    func resolveSequenceOfActions() {
        guard let player = scene.player else { return }
        if player.actions.count == player.currentRoll.rawValue {
            scene.game?.controller?.disable()
            performActionSequence()
        }
    }
    
    /// Perform the sequence of actions.
    func performActionSequence() {
        guard let player = scene.player else { return }
        
        var actions = actionSequenceAction
        actions.append(SKAction.run {
            self.endSequenceOfActions()
            self.dropPlayer()
        })
        
        let sequence = SKAction.sequence(actions)
        
        player.node.run(sequence)
    }
    
    /// End the sequence of actions.
    func endSequenceOfActions() {
        guard let player = scene.player else { return }
        player.actions.removeAll()
        self.scene.core?.hud?.removeActionSquares()
        let sparkEffect = player.node.childNode(withName: GameConfiguration.nodeKey.sparkEffect)
        sparkEffect?.removeFromParent()
    }
}

// MARK: - Falls

extension GameLogic {
    
    /// Returns the coordinate where an object is supposed to stop falling.
    private func fallCoordinate(object: PKObjectNode) -> Coordinate {
        
        let objectCoordinate = object.coordinate
        
        var destinationCoordinate = Coordinate(x: objectCoordinate.x,
                                               y: objectCoordinate.y)
        
        repeat {
            destinationCoordinate.x += 1
        } while !environment.collisionCoordinates.contains(destinationCoordinate) && destinationCoordinate.x <= environment.deathLimit
        
        destinationCoordinate.x -= 1
        
        return destinationCoordinate
    }
    
    /// Returns the position where an object is supposed to stop falling.
    private func fallPosition(object: PKObjectNode) -> CGPoint {
        let coordinate = fallCoordinate(object: object)
        guard let position = environment.map.tilePosition(from: coordinate) else { return .zero }
        
        return position
    }
    
    /// Returns the animation of the object falling at a specific speed.
    private func fallAnimation(object: PKObjectNode, speed: CGFloat) -> SKAction {
        let coordinate = fallCoordinate(object: object)
        let position = fallPosition(object: object)
        let moveAction = SKAction.move(from: object.position, to: position, speed: speed)
        let action = !environment.isCollidingWithObject(at: coordinate) ? moveAction : SKAction.empty()
        
        return action
    }
    
    /// Returns the player land animation after the fall.
    private var playerLandAnimation: SKAction {
        guard let player = scene.player else { return SKAction.empty() }
        let action = SKAction.run {
            self.scene.core?.animation?.addCircularSmokeEffect(scene: self.scene, node: player.node)
            self.scene.core?.animation?.addScreenShakeEffect(on: self.scene)
            self.scene.core?.sound.land(scene: self.scene)
        }
        return action
    }
    
    /// Returns the player land completion animation after the land.
    private var playerLandCompletionAnimation: SKAction {
        return SKAction.run { [weak self] in
            self?.playerLandCompletion()
        }
    }
    
    /// Player land completion.
    private func playerLandCompletion() {
        guard let action = scene.game?.controller?.action else { return }
        scene.game?.controller?.triggerHaptics()
        scene.player?.state.isJumping = false
        scene.core?.state.switchOn(newStatus: .inDefault)
        scene.game?.controller?.enable()
        scene.core?.event?.triggerPlayerDeathFall()
        if action.configuration.isLongPressingDPad {
            scene.player?.node.removeAllActions()
            scene.game?.controller?.action.move(on: action.configuration.direction, by: action.configuration.movementSpeed)
        }
    }
    
    /// Make the player fall if possible.
    func dropPlayer() {
        guard let player = scene.player else { return }
        player.node.removeAllActions()
        let drop = SKAction.sequence([
            fallAnimation(object: player.node, speed: GameConfiguration.playerConfiguration.fallSpeed),
            playerLandAnimation,
            playerLandCompletionAnimation
        ])
        scene.player?.node.run(drop)
    }
    
    /// Make a trap fall repeateadly.
    func dropTrap(trapObject: PKObjectNode) {
        let drop = SKAction.sequence([
            trapFallAnimation(trapObject: trapObject),
            SKAction.run { [weak self] in
                self?.trapCompletion(trapObject: trapObject)
            }
        ])
        
        trapObject.run(drop)
    }
    
    /// Trap Fall
    func trapFallAnimation(trapObject: PKObjectNode) -> SKAction {
        guard let level = scene.game?.level else { return SKAction.empty() }
        guard let levelTrap = LevelObject.indexedObjectNode(object: trapObject, data: level.objects(category: .trap)) else { return SKAction.empty() }
        return fallAnimation(object: trapObject, speed: levelTrap.speed ?? 500)
    }
    
    /// Trap completion.
    func trapCompletion(trapObject: PKObjectNode) {
        guard let level = scene.game?.level else { return }
        guard let levelTrap = LevelObject.indexedObjectNode(object: trapObject, data: level.objects(category: .trap)) else { return }
        scene.core?.animation?.delayedDestroy(scene: scene, node: trapObject, timeInterval: 0.1) {
            if levelTrap.isRespawning {
                self.scene.core?.content?.createLevelTrap(levelTrap)
            }
        }
    }
}

// MARK: - Overall Combat

extension GameLogic {
    
    /// Damage an object with a projectile.
    func damageObject(_ objectNode: PKObjectNode, with projectileNode: PKObjectNode) {
//        guard objectNode.logic.isDestructible else { return }
//        objectNode.logic.healthLost += projectileNode.logic.damage
        damage(objectNode)
    }
    
    /// Returns true is an object is destroyed, false otherwise.
    private func isDestroyed(_ objectNode: PKObjectNode) -> Bool {
        return true
        //objectNode.logic.healthLost >= objectNode.logic.health
    }
    
    /// Destroy an object then play his death animation.
    func instantDestroy(_ objectNode: PKObjectNode) {
//        objectNode.logic.healthLost = objectNode.logic.health
        if isDestroyed(objectNode) {
            objectNode.physicsBody?.categoryBitMask = .zero
            objectNode.physicsBody?.contactTestBitMask = .zero
            objectNode.physicsBody?.collisionBitMask = .zero
            scene.core?.animation?.delayedDestroy(scene: scene,
                                                  node: objectNode,
                                                  timeInterval: 0.1)
        }
    }
    
    /// Destroy an object.
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
    
    /// Hit an object.
    private func hit(_ objectNode: PKObjectNode) {
        scene.core?.animation?.hit(node: objectNode,
                                   filteringMode: .nearest)
    }
    
    /// Damage an object
    private func damage(_ objectNode: PKObjectNode) {
        hit(objectNode)
        destroy(objectNode)
    }
}

// MARK: - Player Combat

extension GameLogic {
    
    /// Damage player.
    func damagePlayer(with enemyNode: PKObjectNode) {
        guard let player = scene.player else { return }
//        player.consumeEnergy(amount: enemyNode.logic.damage)
        scene.core?.hud?.updateEnergy()
        playerDestroy()
    }
    
    /// Destroy the player.
    func playerDestroy() {
        guard let player = scene.player else { return }
        if player.isOutOfEnergy {
            player.state.isDead = true
            player.death(scene: scene)
            scene.core?.hud?.removeContent()
            scene.game?.controller?.disable()
            scene.core?.animation?.sceneTransitionEffect(scene: scene,
                                                         effectAction: SKAction.fadeIn(withDuration: 2),
                                                         isFadeIn: false,
                                                         isShowingTitle: false) {
                self.scene.core?.event?.restartLevel()
            }
        }
    }
}
