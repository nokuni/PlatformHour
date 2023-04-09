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
    
    /// Dismiss the current pop up button.
    public func dismissButtonPopUp() {
        guard let popUpButton = scene.childNode(withName: GameConfiguration.nodeKey.popUpButton) else {
            return
        }
        print("popUpButton removed")
        popUpButton.removeFromParent()
        scene.player?.interactionStatus = .none
    }
    
    /// Load the next level of the game.
    public func loadNextLevel() {
        scene.core?.animation?.transitionEffect(effect: SKAction.fadeIn(withDuration: 2),
                                                isVisible: false,
                                                scene: scene) {
            self.scene.game?.setupNextLevel()
            self.restartLevel()
        }
    }
    
    /// Restart the current level of the game.
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

    
    // MARK: - Triggers
    
    /// Trigger a dialog.
    public func triggerDialog() {
        guard let level = scene.game?.level else { return }
        guard let player = scene.player else { return }
        
        if let dialog = level.dialogs.first(where: {
            $0.triggerCoordinate.coordinate == player.node.coordinate
        }) {
            if dialog.isDialogAvailable {
                scene.game?.currentLevelDialog = dialog
                scene.core?.state.switchOn(newStatus: .inDialog)
                scene.core?.hud?.generateDialogBox()
            }
        }
    }
    
    /// Trigger an interaction pop up.
    public func triggerInteractionPopUp(at coordinate: Coordinate) {
        guard let environment = scene.core?.environment else { return }
        if let position = environment.map.tilePosition(from: coordinate) {
            let buttonPosition = CGPoint(x: position.x, y: position.y + (GameConfiguration.sceneConfiguration.tileSize.height * 2))
            environment.generatePopUpButton(buttonSymbol: .y, position: buttonPosition)
        }
    }
    
    /// Trigger the player death fall.
    public func triggerPlayerDeathFall() {
        guard let player = scene.player else { return }
        guard let environment = scene.core?.environment else { return }
        guard player.node.coordinate.x >= environment.deathLimit else {
            return
        }
        
        player.state.isDead = true
        
        if player.state.isDead {
            player.state.isDead = false
            scene.core?.animation?.transitionEffect(effect: SKAction.fadeIn(withDuration: 2),
                                                   isVisible: false,
                                                   scene: scene) {
                self.restartLevel()
            }
        }
    }
    
    // MARK: - Updates
    
    /// Updates player coordinate
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
    
    // MARK: - Cinematics
    
    public func spiritIntroCinematic(node: SKNode) {
        //guard let spiritNPC = scene.game?.level?.npcs.first else { return }
        //scene.core?.content?.createNPC(spiritNPC)
    }
}
