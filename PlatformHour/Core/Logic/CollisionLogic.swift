//
//  CollisionLogic.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import SpriteKit
import PlayfulKit

public class CollisionLogic {
    
    public init(scene: GameScene) {
        self.scene = scene
    }
    
    public var scene: GameScene
    
    public func projectileHitObject(_ projectileNode: PKObjectNode, objectNode: PKObjectNode) {
        scene.core?.logic?.damageObject(objectNode, with: projectileNode)
        projectileNode.removeAllActions()
        scene.player?.isProjectileTurningBack = true
    }
    
    public func pickUpItem(object: PKObjectNode, name: String) {
        if let item = try? GameItem.get(name) {
            scene.player?.bag.append(item)
            scene.core?.hud?.updateItemAmountHUD()
            object.removeFromParent()
        }
    }
    
    public func landOnGround() {
        guard let player = scene.player else { return }
        guard let enviroment = scene.core?.environment else { return }
        guard let position = enviroment.map.tilePosition(from: player.node.coordinate) else { return }
        
        if player.isJumping {
            player.node.run(SKAction.move(to: position, duration: 0.1))
            player.node.physicsBody?.velocity = .zero
            player.isJumping = false
        }
    }
    
    public func quitLevel() {
        //scene.game?.goToNextLevel()
        scene.removeAllActions()
        scene.removeAllChildren()
        scene.startGame()
    }
}
