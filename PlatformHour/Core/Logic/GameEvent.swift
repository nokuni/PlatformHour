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
    
    public var scene: GameScene
    
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
            self.scene.launch()
        },
                                                           isRepeating: true)
        let timerNode = PKTimerNode(configuration: configuration)
        scene.addChildSafely(timerNode)
        timerNode.start()
    }
    
    
    // MARK: - Triggers
    
    /// Trigger a level dialog.
    public func triggerDialogOnCoordinate() {
        guard let level = scene.game?.level else { return }
        guard let player = scene.player else { return }
        
        if let levelDialog = level.dialogs.first(where: {
            $0.triggerCoordinate?.coordinate == player.node.coordinate
        }) {
            playDialog(levelDialog: levelDialog)
        }
    }
    
    /// Trigger a level cinematic when the player move on a specific coordinate.
    public func triggerCinematicOnCoordinate() {
        guard let level = scene.game?.level else { return }
        guard let player = scene.player else { return }
        
        guard let cinematic = level.cinematics.first(where: { $0.triggerCoordinate?.coordinate == player.node.coordinate }) else { return }
        
        playCinematic(cinematic: cinematic)
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
    
    // MARK: - Dialogs
    
    /// Play the current dialog.
    public func playDialog(levelDialog: LevelDialog) {
        guard levelDialog.isAvailable else { return }
        
        scene.game?.currentLevelDialog = levelDialog
        scene.core?.state.switchOn(newStatus: .inDialog)
        scene.core?.hud?.generateDialogBox()
    }
    
    // MARK: - Cinematics
    
    /// Play a level cinematic.
    public func playCinematic(cinematic: LevelCinematic) {
        guard let level = scene.game?.level else { return }
        guard let player = scene.player else { return }
        guard cinematic.isAvailable else { return }
        
        scene.game?.currentLevelCinematic = cinematic
        scene.core?.state.switchOn(newStatus: .inCinematic)
        if let cinematicData = GameCinematic.get(cinematic.name) {
            let actions: [(SKAction, PKObjectNode)] = cinematicData.actions.compactMap {
                cinematicNodeAction(action: $0)
            }
            SKAction.nodesSequence(sequence: actions, endCompletion: {
                if let dialog = cinematicData.dialogCompletion,
                   let levelDialog = level.dialogs.first(where: { $0.dialog == dialog }) {
                    self.playDialog(levelDialog: levelDialog)
                    self.scene.core?.gameCamera?.followedObject = player.node
                }
            })
        }
    }
    
    /// Returns the object and the action of the cinematic sequence.
    private func cinematicNodeAction(action: GameCharacterCinematicAction) -> (SKAction, PKObjectNode)? {
        guard let objectNode = cinematicObjectNode(action: action) else { return nil }
        
        objectNode.zPosition = GameConfiguration.sceneConfiguration.hudZPosition
        
        let action = cinematicAction(objectNode: objectNode, action: action)
        
        return (action, objectNode)
    }
    
    /// Returns the action of the cinematic sequence.
    private func cinematicAction(objectNode: PKObjectNode,
                                 action: GameCharacterCinematicAction) -> SKAction {
        
        guard let environment = scene.core?.environment else { return SKAction.empty() }
        guard let animation = scene.core?.animation else { return SKAction.empty() }
        
        if action.isFollowedByCamera {
            scene.core?.gameCamera?.followedObject = objectNode
        }
        
        var actions: [SKAction] = []
        
        if let effect = action.effect,
           let stateIDIdentifier = GameAnimation.StateID(rawValue: effect.stateIDIdentifier) {
            let spriteAnimation = animation.animate(node: objectNode,
                                                    identifier: stateIDIdentifier,
                                                    filteringMode: .nearest,
                                                    timeInterval: 0.1)
            let objectAnimation = effect.isRepeatingForever ? SKAction.repeatForever(spriteAnimation) : spriteAnimation
            if action.movement == nil {
                actions.append(objectAnimation)
                actions.append(SKAction.removeFromParent())
            } else {
                objectNode.run(objectAnimation)
            }
        }
        
        if let movement = action.movement,
           let destinationPosition = environment.map.tilePosition(from: movement.destinationCoordinate.coordinate) {
            let moveAction = SKAction.move(to: destinationPosition, duration: 5)
            let groupAnimation = SKAction.group([moveAction])
            let disappear = movement.willDisappear ? SKAction.removeFromParent() : SKAction.empty()
            actions.append(groupAnimation)
            actions.append(disappear)
        }
        
        let action = SKAction.sequence(actions)
        
        return action
    }
    
    /// Return the object linked with the action of the current cinematic sequence.
    private func cinematicObjectNode(action: GameCharacterCinematicAction) -> PKObjectNode? {
        guard let gameObject = GameObject.getNPC(action.objectName) else { return nil }
        if let objectNode = scene.childNode(withName: gameObject.name) as? PKObjectNode {
            return objectNode
        } else {
            if let startingCoordinate = action.startingCoordinate?.coordinate {
                scene.core?.content?.createNPC(gameObject, at: startingCoordinate)
            }
            if let objectNode = scene.childNode(withName: gameObject.name) as? PKObjectNode  {
                return objectNode
            }
        }
        return nil
    }
    
    /// Disable the current level cinematic. (To not trigger it again.)
    private func disableCinematic() {
        if let index = scene.game?.level?.cinematics.firstIndex(where: {
            $0.name == scene.game?.currentLevelCinematic?.name
        }) {
            scene.game?.level?.cinematics[index].isAvailable = false
        }
    }
}

// When to play cinematic ?

// After the title of the level has been displayed
// When the player is on a specific coordinate.
// After a node has been altered.
