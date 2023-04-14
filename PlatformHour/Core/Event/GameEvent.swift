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
        popUpButton.removeFromParent()
        scene.player?.interactionStatus = .none
    }
    
    /// Load the next level of the game.
    public func loadNextLevel() {
        scene.core?.event?.dismissButtonPopUp()
        scene.core?.hud?.removeContent()
        scene.game?.controller?.disable()
        scene.core?.animation?.sceneTransitionEffect(scene: scene,
                                                     effectAction: SKAction.fadeIn(withDuration: 2),
                                                     isFadeIn: false,
                                                     isShowingTitle: false,
                                                     completion: {
            self.scene.game?.setupNextLevel()
            self.restartLevel()
        })
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
    
    // MARK: - Conversations
    
    /// Play the current conversation.
    public func playConversation(levelConversation: LevelConversation) {
        guard levelConversation.isAvailable else { return }
        
        scene.game?.currentLevelConversation = levelConversation
        scene.core?.state.switchOn(newStatus: .inConversation)
        scene.core?.hud?.addConversationBox()
    }
    
    // MARK: - Cinematics
    
    /// Play a level cinematic.
    public func startCinematic(levelCinematic: LevelCinematic) {
        guard levelCinematic.isAvailable else { return }
        
        scene.game?.currentLevelCinematic = levelCinematic
        scene.core?.state.switchOn(newStatus: .inCinematic)
        playCinematicSequence(levelCinematic: levelCinematic)
    }
    
    private func playCinematicSequence(levelCinematic: LevelCinematic) {
        if let cinematic = GameCinematic.get(levelCinematic.name) {
            let actions: [(SKAction, PKObjectNode)] = cinematic.actions.compactMap {
                cinematicNodeAction(action: $0)
            }
            SKAction.nodesSequence(sequence: actions, endCompletion: {
                self.cinematicSequence(cinematic: cinematic)
            })
        }
    }
    
    private func cinematicSequence(cinematic: GameCinematic) {
        guard let level = scene.game?.level else { return }
        guard let player = scene.player else { return }
        if let conversation = cinematic.conversationCompletion,
           let levelConversation = level.conversations.first(where: { $0.conversation == conversation }) {
            self.playConversation(levelConversation: levelConversation)
            self.scene.core?.gameCamera?.followedObject = player.node
            self.scene.isUserInteractionEnabled = true
        }
    }
    
    /// Returns the object and the action of the cinematic sequence.
    private func cinematicNodeAction(action: CinematicAction) -> (SKAction, PKObjectNode)? {
        guard let cinematicNode = cinematicNode(action: action) else { return nil }
        let action = cinematicAction(node: cinematicNode, action: action)
        return (action, cinematicNode)
    }
    
    /// Returns the action of showing a node.
    private func showCinematicNode(node: PKObjectNode) -> SKAction {
        SKAction.run { node.alpha = 1 }
    }
    
    /// Returns the animation effect of the current cinematic node.
    private func cinematicNodeEffect(node: PKObjectNode, action: CinematicAction) -> [SKAction] {
        guard let animation = scene.core?.animation else { return [] }
        var actions: [SKAction] = []
        
        guard let effect = action.effect else { return [] }
        guard let stateIDIdentifier = GameAnimation.StateID(rawValue: effect.stateIDIdentifier) else {
            return []
        }
        
        let spriteAnimation = animation.animate(node: node,
                                                identifier: stateIDIdentifier,
                                                filteringMode: .nearest,
                                                timeInterval: 0.1)
        
        var objectAnimation: SKAction = SKAction.empty()
        
        switch true {
        case effect.repeatCount != nil:
            objectAnimation = SKAction.repeat(spriteAnimation, count: effect.repeatCount!)
        case effect.isRepeatingForever:
            objectAnimation = SKAction.repeatForever(spriteAnimation)
        default:
            objectAnimation = spriteAnimation
        }
        
        switch true {
        case action.movement == nil:
            actions.append(objectAnimation)
            actions.append(SKAction.removeFromParent())
        default:
            node.run(objectAnimation)
        }
        
        return actions
    }
    
    /// Returns the animation movement of the current cinematic node.
    private func cinematicNodeMovement(node: PKObjectNode, action: CinematicAction) -> [SKAction] {
        guard let environment = scene.core?.environment else { return [] }
        var actions: [SKAction] = []
        let cameraAction = SKAction.run { self.scene.core?.gameCamera?.followedObject = node }
        if let movement = action.movement,
           let destinationPosition = environment.map.tilePosition(from: movement.destinationCoordinate.coordinate) {
            let moveAction = SKAction.move(to: destinationPosition, duration: movement.duration)
            let groupAnimation = SKAction.group([moveAction])
            let disappear = movement.willDisappear ? SKAction.removeFromParent() : SKAction.empty()
            actions.append(action.isFollowedByCamera ? cameraAction : SKAction.empty())
            actions.append(groupAnimation)
            actions.append(disappear)
        }
        return actions
    }
    
    /// Returns the action of the cinematic sequence.
    private func cinematicAction(node: PKObjectNode,
                                 action: CinematicAction) -> SKAction {
        var actions: [SKAction] = []
        
        actions.append(showCinematicNode(node: node))
        actions.append(contentsOf: cinematicNodeEffect(node: node, action: action))
        actions.append(contentsOf: cinematicNodeMovement(node: node, action: action))
        
        let action = SKAction.sequence(actions)
        
        return action
    }
    
    /// Create the asked node for the cinematic if there is none on the scene.
    private func cinematicNode(action: CinematicAction) -> PKObjectNode? {
        guard let object = GameObject.get(action.objectName) else { return nil }
        guard let startingCoordinate = action.startingCoordinate?.coordinate else { return nil }
        
        let objectNode = scene.core?.content?.createObject(object, at: startingCoordinate)
        objectNode?.zPosition = GameConfiguration.sceneConfiguration.hudZPosition
        objectNode?.alpha = 0
        
        return objectNode
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

// MARK: - Triggers

extension GameEvent {
    
    /// Trigger a level conversation on when the player is on a specific coordinate.
    public func triggerConversationOnCoordinate() {
        guard let level = scene.game?.level else { return }
        guard let player = scene.player else { return }
        
        if let levelConversation = level.conversations.first(where: {
            $0.triggerCoordinate?.coordinate == player.node.coordinate
        }) {
            playConversation(levelConversation: levelConversation)
        }
    }
    
    /// Trigger a level cinematic when the player is on a specific coordinate.
    public func triggerCinematicOnCoordinate() {
        guard let level = scene.game?.level else { return }
        guard let player = scene.player else { return }
        
        guard let cinematic = level.cinematics.first(where: { $0.triggerCoordinate?.coordinate == player.node.coordinate }) else { return }
        
        startCinematic(levelCinematic: cinematic)
    }
    
    /// Trigger an interaction pop up when the player is on specific coordinate.
    public func triggerInteractionPopUp(at coordinate: Coordinate) {
        guard let environment = scene.core?.environment else { return }
        if let position = environment.map.tilePosition(from: coordinate) {
            let buttonPosition = CGPoint(x: position.x, y: position.y + (GameConfiguration.sceneConfiguration.tileSize.height * 2))
            environment.createPopUpButton(buttonSymbol: .y, position: buttonPosition)
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
            scene.core?.animation?.sceneTransitionEffect(scene: scene,
                                                         effectAction: SKAction.fadeIn(withDuration: 2),
                                                         isFadeIn: false,
                                                         isShowingTitle: false) {
                self.restartLevel()
            }
        }
    }
}
