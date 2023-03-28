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
        scene.core?.animation.transitionEffect(effect: SKAction.fadeIn(withDuration: 2),
                                               isVisible: false,
                                               scene: scene) {
            self.scene.game?.setupNextLevel()
            self.restartLevel()
        }
    }
    
    public func restartLevel(delayedBy seconds: Double = 0) {
        let configuration = PKTimerNode.TimerConfiguration(countdown: seconds,
                                                           counter: 1,
                                                           timeInterval: 1,
                                                           actionOnLaunch: nil,
                                                           actionOnGoing: nil,
                                                           actionOnEnd: {
            self.scene.removeAllActions()
            self.scene.removeAllChildren()
            self.scene.startGame()
        },
                                                           isRepeating: true)
        let timerNode = PKTimerNode(configuration: configuration)
        scene.addChildSafely(timerNode)
        timerNode.start()
    }
    
    // Updates
    public func triggerPlayerDeathFall() {
        guard let player = scene.player else { return }
        guard player.node.coordinate.x >= GameConfiguration.worldConfiguration.xDeathBoundary else {
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
    
//    public func updatePlatformCoordinates() {
//        guard let environment = scene.core?.environment else { return }
//        let platform = environment.map.objects.first { $0.name == "Platform" }
//        guard let platform = platform else { return }
//        
//        let element = environment.allElements.first {
//            $0.contains(platform.position)
//        }
//        
//        if let tileElement = element as? PKTileNode {
//            platform.coordinate = tileElement.coordinate
//        }
//        
//        if let objectElement = element as? PKObjectNode {
//            platform.coordinate = objectElement.coordinate
//        }
//    }
}
