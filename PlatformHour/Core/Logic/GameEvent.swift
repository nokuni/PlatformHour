//
//  GameEvent.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 14/03/23.
//

import SpriteKit
import PlayfulKit
import Utility_Toolbox

public final class GameEvent {
    
    public init(scene: GameScene) {
        self.scene = scene
    }
    
    var scene: GameScene
    
    // Dismisses
    public func dismissButtonPopUp() {
        guard let buttonPopUp = scene.childNode(withName: GameConfiguration.sceneConfigurationKey.buttonPopUp) else {
            return
        }
        buttonPopUp.removeFromParent()
        scene.player?.interactionStatus = .none
    }
    
    // Level
    public func loadNextLevel() {
        scene.isUserInteractionEnabled = false
        let smoke = SKShapeNode(rectOf: scene.size * 2)
        smoke.alpha = 0
        smoke.fillColor = .white
        smoke.strokeColor = .white
        smoke.position = scene.player?.node.position ?? .zero
        scene.addChild(smoke)
        let sequence = SKAction.sequence([
            SKAction.fadeIn(withDuration: 2),
            SKAction.run {
                self.scene.game?.setupNextLevel()
                self.restartLevel()
            }
        ])
        smoke.run(sequence)
    }
    public func restartLevel() {
        scene.removeAllActions()
        scene.removeAllChildren()
        scene.startGame()
    }
    
    // Updates
    public func triggerPlayerDeathFall() {
        guard let player = scene.player else { return }
        guard player.node.coordinate.x > GameConfiguration.worldConfiguration.xDeathBoundary else {
            return
        }
        player.isDead = true
        if player.isDead {
            player.isDead = false
            scene.core?.animation.transitionEffect(effect: SKAction.fadeIn(withDuration: 2),
                                                   isVisible: false,
                                                   scene: scene) {
                self.restartLevel()
            }
        }
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
}
