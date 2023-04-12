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
            scene.core?.animation?.delayedDestroy(scene: scene,
                                                  node: objectNode,
                                                  timeInterval: 0.1)
        }
    }
    
    private func playerDestroy() {
        guard let player = scene.player else { return }
        if isDestroyed(player.node) {
            player.death(scene: scene)
            scene.core?.animation?.sceneTransitionEffect(scene: scene,
                                                         effectAction: SKAction.fadeIn(withDuration: 2),
                                                         isFadeIn: false,
                                                         isShowingTitle: false) {
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
    
    // MARK: - Falls
    
    /// Returns the coordinate where an object is supposed to stop falling.
    private func fallCoordinate(object: PKObjectNode) -> Coordinate {
        
        let objectCoordinate = object.coordinate
        
        var destinationCoordinate = Coordinate(x: objectCoordinate.x + 1,
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
            self.scene.core?.animation?.addCircularSmokeEffect(on: player.node)
            self.scene.core?.animation?.addScreenShakeEffect(on: self.scene)
            self.scene.core?.sound.land(scene: self.scene)
        }
        return action
    }
    
    /// Returns the player land completion animation after the land.
    private var playerLandCompletionAnimation: SKAction {
        let action = SKAction.run {
            self.scene.player?.state.isJumping = false
            self.scene.core?.state.switchOn(newStatus: .inDefault)
            self.enableControls()
        }
        return action
    }
    
    /// Make the player fall if possible.
    public func dropPlayer() {
        guard let player = scene.player else { return }
        player.node.removeAllActions()
        let drop = SKAction.sequence([
            fallAnimation(object: player.node, speed: GameConfiguration.playerConfiguration.fallSpeed),
            playerLandAnimation,
            SKAction.wait(forDuration: 0.5),
            playerLandCompletionAnimation
        ])
        scene.player?.node.run(drop)
    }
    
    /// Make a trap fall repeateadly.
    public func dropTrap(trapObject: PKObjectNode) {
        guard let level = scene.game?.level else { return }
        guard let levelTrap = indexedLevelObject(object: trapObject, data: level.objects(category: .trap)) else { return }
        
        let drop = SKAction.sequence([
            fallAnimation(object: trapObject, speed: 500),
            SKAction.run {
                self.scene.core?.animation?.delayedDestroy(scene: self.scene, node: trapObject, timeInterval: 0.1) {
                    self.scene.core?.content?.createLevelTrap(levelTrap)
                }
            }
        ])
        
        trapObject.run(drop)
    }
    
    // MARK: - Player Action Sequence
    
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
        
        let positions = coordinates.compactMap { environment.map.tilePosition(from: $0) }
        
        let moves = positions.map {
            SKAction.move(to: $0, duration: 0.2)
        }
        
        return moves
    }
    
    /// Resolve the perform of the sequence of actions.
    public func resolveSequenceOfActions() {
        guard let player = scene.player else { return }
        if player.actions.count == player.currentRoll.rawValue {
            let gravityEffect = player.node.childNode(withName: GameConfiguration.nodeKey.gravityEffect)
            gravityEffect?.removeFromParent()
            disableControls()
            performActionSequence()
        }
    }
    
    /// Perform the sequence of actions.
    public func performActionSequence() {
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
    public func endSequenceOfActions() {
        guard let player = scene.player else { return }
        player.actions.removeAll()
        self.scene.core?.hud?.removeActionSquares()
    }
    
    // Projectiles
    public func projectileFollowPlayer() {
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
    
    // MARK: - Controls
    
    /// Disable the controls on the scene.
    public func disableControls() {
        scene.game?.controller?.manager?.action = nil
        scene.isUserInteractionEnabled = false
    }
    
    /// Enable the controls on the scene.
    public func enableControls() {
        scene.game?.controller?.setupActions()
        scene.isUserInteractionEnabled = true
    }
    
    // MARK: - Miscellaneous
    
    public func indexedLevelObject<Element: LevelProtocol>(object: PKObjectNode,
                                                           data: [Element]) -> Element? {
        guard let objectName = object.name else { return nil }
        guard let id = objectName.extractedNumber else { return nil }
        let element = data.first(where: { $0.id == id })
        return element
    }
}
