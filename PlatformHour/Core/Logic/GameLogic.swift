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
    
    private func destroy(_ objectNode: PKObjectNode) {
        if isDestroyed(objectNode) {
            objectNode.physicsBody?.categoryBitMask = .zero
            objectNode.physicsBody?.contactTestBitMask = .zero
            objectNode.physicsBody?.collisionBitMask = .zero
            scene.core?.animation.destroy(node: objectNode,
                              filteringMode: .nearest) {
                if let item = objectNode.drops.first as? GameItem {
                    self.scene.core?.content?.dropItem(item, at: objectNode.coordinate)
                }
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
    
    public func openExitDoor() {
        guard let exitDoor = scene.childNode(withName: GameConfiguration.sceneConfigurationKey.exitDoor) else { return }
        let sequence = SKAction.sequence([
            SKAction.fadeOutAndIn(fadeOutDuration: 0.05, fadeInDuration: 0.05, repeating: 10),
            SKAction.removeFromParent()
        ])
        exitDoor.run(sequence)
    }
    
    public func updatePlayerCoordinate() {
        guard let player = scene.player else { return }
        guard let environment = scene.core?.environment else { return }
        
        let element = environment.allElements.first { $0.contains(player.node.position) }
        
        if let tileElement = element as? PKTileNode {
            player.node.coordinate = tileElement.coordinate
        }
        
        if let objectElement = element as? PKObjectNode {
            player.node.coordinate = objectElement.coordinate
        }
    }
    
    public func disableControls() {
        scene.game?.controller?.manager?.action = nil
        scene.isUserInteractionEnabled = false
    }
    
    public func enableControls() {
        scene.game?.controller?.setupActions()
        scene.isUserInteractionEnabled = true
    }
}
