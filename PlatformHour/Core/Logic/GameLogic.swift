//
//  GameLogic.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 05/02/23.
//

import SpriteKit
import PlayfulKit
import Utility_Toolbox

final public class GameLogic {
    
    public init(scene: GameScene) {
        self.scene = scene
    }
    
    public var scene: GameScene
    
    public func damageObject(_ objectNode: PKObjectNode, with projectileNode: PKObjectNode) {
        guard objectNode.logic.isDestructible else { return }
        objectNode.logic.healthLost += projectileNode.logic.damage
        damage(objectNode)
    }
    
    private func isDestroyed(_ objectNode: PKObjectNode) -> Bool {
        objectNode.logic.healthLost >= objectNode.logic.health
    }
    
    private func instantDestroy(_ objectNode: PKObjectNode) {
        objectNode.logic.healthLost = objectNode.logic.health
        if isDestroyed(objectNode) {
            objectNode.physicsBody?.categoryBitMask = .zero
            objectNode.physicsBody?.contactTestBitMask = .zero
            objectNode.physicsBody?.collisionBitMask = .zero
            scene.core?.animation.destroyThenAnimate(scene: scene,
                                                     node: objectNode,
                                                     timeInterval: 0.1)
        }
    }
    
    private func destroy(_ objectNode: PKObjectNode) {
        if isDestroyed(objectNode) {
            objectNode.physicsBody?.categoryBitMask = .zero
            objectNode.physicsBody?.contactTestBitMask = .zero
            objectNode.physicsBody?.collisionBitMask = .zero
            scene.core?.animation.destroy(node: objectNode,
                                          filteringMode: .nearest) {
                //                if let item = objectNode.drops.first as? GameItem {
                //                    self.scene.core?.content?.dropItem(item, at: objectNode.coordinate)
                //                }
            }
        }
    }
    
    private func hit(_ objectNode: PKObjectNode) {
        scene.core?.animation.hit(node: objectNode,
                                  filteringMode: .nearest)
    }
    
    private func damage(_ objectNode: PKObjectNode) {
        hit(objectNode)
        destroy(objectNode)
    }
    
    private func dropDestroyCube(coordinate: Coordinate) {
        guard let environment = scene.core?.environment else { return }
        if let cube = environment.map.objects.first(where: {
            guard let name = $0.name else { return false }
            return name.contains("Cube") && $0.coordinate == coordinate
        }) {
            print("Destroy Cube")
            instantDestroy(cube)
        }
    }
    
    // Drop
    private var dropCoordinate: Coordinate {
        guard let player = scene.player else { return .zero }
        guard let environment = scene.core?.environment else { return .zero }
        
        let playerCoordinate = player.node.coordinate
        
        var destinationCoordinate = Coordinate(x: playerCoordinate.x + 1,
                                               y: playerCoordinate.y)
        
        repeat {
            dropDestroyCube(coordinate: destinationCoordinate)
            destinationCoordinate.x += 1
            dropDestroyCube(coordinate: destinationCoordinate)
        } while !environment.collisionCoordinates.contains(destinationCoordinate) && destinationCoordinate.x <= GameConfiguration.worldConfiguration.xDeathBoundary
        
        destinationCoordinate.x -= 1
        
        return destinationCoordinate
    }
    private var dropPosition: CGPoint {
        guard let environment = scene.core?.environment else { return .zero }
        guard let position = environment.map.tilePosition(from: dropCoordinate) else { return .zero }
        
        return position
    }
    private var dropAction: SKAction {
        guard let player = scene.player else { return SKAction.empty() }
        guard let environment = scene.core?.environment else { return SKAction.empty() }
        
        let moveAction = SKAction.move(from: player.node.position, to: dropPosition, at: 1000)
        let action = !environment.isCollidingWithObject(at: dropCoordinate) ? moveAction : SKAction.empty()
        
        return action
    }
    private var landAction: SKAction {
        guard let player = scene.player else { return SKAction.empty() }
        let action = SKAction.run {
            self.scene.core?.animation.circularSmoke(on: player.node)
            self.scene.player?.state = .normal
            self.enableControls()
        }
        return action
    }
    
    public func dropPlayer() {
        scene.player?.node.removeAllActions()
        let drop = SKAction.sequence([dropAction, landAction])
        scene.player?.node.run(drop)
    }
    
    // Action Sequence
    private var actionSequenceAction: [SKAction] {
        guard let player = scene.player else { return [] }
        guard let environment = scene.core?.environment else { return [] }
        
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
    private var endActionSequenceAction: SKAction {
        guard let player = scene.player else { return SKAction.empty() }
        let action = SKAction.run {
            player.actions.removeAll()
            self.scene.core?.hud?.removeDiceActions()
            self.dropPlayer()
        }
        return action
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
        actions.append(endActionSequenceAction)
        
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
