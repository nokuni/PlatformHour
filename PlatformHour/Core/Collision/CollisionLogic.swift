//
//  CollisionLogic.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import SpriteKit
import PlayfulKit

final class CollisionLogic {
    
    init(scene: GameScene) {
        self.scene = scene
    }
    
    var scene: GameScene
    
    /// When the player projectile hit an object.
    func projectileHitObject(_ projectileNode: PKObjectNode, objectNode: PKObjectNode) {
        scene.core?.logic?.damageObject(objectNode, with: projectileNode)
        projectileNode.removeAllActions()
        scene.player?.state.hasProjectileTurningBack = true
    }
    
    /// When the player pick up an item.
    func pickUpCollectible(object: PKObjectNode) {
        if let objectName = object.name,
           let collectibleData = GameObject.getCollectible(objectName) {
            if let collectibleSound = collectibleData.sound {
                try? scene.core?.sound.manager.playSFX(name: collectibleSound, volume: 0.1)
            }
            scene.player?.bag.append(collectibleData)
            scene.core?.hud?.updateGemScore()
            scene.core?.animation?.delayedDestroy(scene: scene,
                                                  node: object,
                                                  timeInterval: 0.1)
        }
    }
    
    /// When the player drop on the head of an enemy.
    func playerDropOnEnemy(_ enemyNode: PKObjectNode) {
        guard let player = scene.player else { return }
        if player.state.isJumping {
            scene.core?.logic?.instantDestroy(enemyNode)
        }
    }
    
    /// When the player has been hitten by a hostile object.
    func hostileHitOnPlayer(_ hostileObject: PKObjectNode) {
        scene.player?.knockBackHitted(scene: scene, by: hostileObject, onRight: false)
        scene.core?.logic?.damagePlayer(with: hostileObject)
    }
    
    /// When the player touch/move an interactive object, reset his position after a delay.
    func resetInteractiveObjectPosition(object: PKObjectNode) {
        guard let level = scene.game?.level else { return }
        guard let indexedObject = LevelObject.indexedObjectNode(object: object, data: level.objects(category: .interactive)) else { return }
        let timerConfiguration = PKTimerNode.TimerConfiguration(countdown: 2,
                                                                counter: 1,
                                                                timeInterval: 1,
                                                                actionOnEnd: {
            object.removeFromParent()
            self.scene.core?.content?.createLevelInteractive(indexedObject)
            
        })
        let timerNode = PKTimerNode(configuration: timerConfiguration)
        object.addChildSafely(timerNode)
        timerNode.start()
    }
    
    func keyOpenLock(key: PKObjectNode, lock: PKObjectNode) {
        let animation = SKAction.sequence([
            SKAction.run { key.physicsBody = nil },
            SKAction.move(to: lock.position, duration: 0.5),
            SKAction.run {
                key.removeAllChildren()
                key.removeAllActions()
                if let image = key.animations.first?.frames.first {
                    key.texture = SKTexture(imageNamed: image)
                    key.texture?.filteringMode = .nearest
                }
            }
            //SKAction.scale(to: 0.7, duration: 0.5),
//            SKAction.fadeOut(withDuration: 0.5),
//            SKAction.removeFromParent(),
//            SKAction.run { lock.removeFromParent() }
        ])
        key.run(animation)
    }
    
    /// When the player land on a structure.
    func landOnGround() {
        guard let player = scene.player else { return }
        
        if player.state.isJumping {
            player.state.isJumping = false
        }
    }
}
