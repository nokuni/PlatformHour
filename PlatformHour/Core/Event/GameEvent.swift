//
//  GameEvent.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 14/03/23.
//

import SpriteKit
import PlayfulKit
import Utility_Toolbox

final class GameEvent {
    
    init(scene: GameScene) {
        self.scene = scene
    }
    
    var scene: GameScene
}

// MARK: - Triggers

extension GameEvent {
    
    /// Trigger a level conversation on when the player is on a specific coordinate.
    func triggerConversationOnCoordinate() {
        guard let level = scene.game?.level else { return }
        guard let player = scene.player else { return }
        
        if let levelConversation = level.conversations.first(where: {
            $0.triggerCoordinate?.coordinate == player.node.coordinate
        }) {
            playConversation(levelConversation: levelConversation)
        }
    }
    
    /// Trigger a level cinematic when the player is on a specific coordinate.
    func triggerCinematicOnCoordinate() {
        guard let level = scene.game?.level else { return }
        guard let player = scene.player else { return }
        
        guard let cinematic = level.cinematics.first(where: { $0.triggerCoordinate?.coordinate == player.node.coordinate }) else { return }
        
        startCinematic(levelCinematic: cinematic)
    }
    
    /// Trigger an interaction pop up when the player is on specific coordinate.
    func triggerInteractionPopUp(at coordinate: Coordinate) {
        guard let environment = scene.core?.environment else { return }
        if let position = environment.map.tilePosition(from: coordinate) {
            let buttonPosition = CGPoint(x: position.x, y: position.y + (GameConfiguration.sceneConfiguration.tileSize.height * 2))
            environment.createPopUpButton(buttonSymbol: .y, position: buttonPosition)
        }
    }
    
    /// Trigger the player death fall.
    func triggerPlayerDeathFall() {
        guard let player = scene.player else { return }
        guard let environment = scene.core?.environment else { return }
        guard player.node.coordinate.x >= environment.deathLimit else { return }
        
        player.state.isDead = true
        
        if player.state.isDead {
            player.state.isDead = false
            scene.core?.hud?.removeContent()
            scene.game?.controller?.disable()
            scene.core?.animation?.sceneTransitionEffect(scene: scene,
                                                         effectAction: SKAction.fadeIn(withDuration: 2),
                                                         isFadeIn: false,
                                                         isShowingTitle: false) {
                self.restartLevel()
            }
        }
    }
}

// MARK: - Cinematics

extension GameEvent {
    
    /// Start a level cinematic.
    func startCinematic(levelCinematic: LevelCinematic) {
        guard let game = scene.game else { return }
        guard game.isCinematicAvailable else { return }
        
        scene.game?.currentLevelCinematic = levelCinematic
        scene.core?.state.switchOn(newStatus: .inCinematic)
        playCinematicSequence(levelCinematic: levelCinematic)
    }
    
    /// Play a level cinematic sequence
    private func playCinematicSequence(levelCinematic: LevelCinematic) {
        if let cinematic = GameCinematic.get(levelCinematic.name) {
            let actions: [(SKAction, PKObjectNode)] = cinematic.actions.compactMap {
                cinematicNodeAction(action: $0)
            }
            SKAction.nodesSequence(sequence: actions, endCompletion: {
                self.cinematicEndCompletion(cinematic: cinematic)
            })
        }
    }
    
    /// The cinematic completion.
    private func cinematicEndCompletion(cinematic: GameCinematic) {
        specialCinematicCompletion(cinematic: cinematic)
        endCinematic(cinematic: cinematic)
        disableCinematic()
        resetCinematic()
    }
    
    /// End current cinematic.
    private func endCinematic(cinematic: GameCinematic) {
        guard let level = scene.game?.level else { return }
        guard let player = scene.player else { return }
        
        if let conversation = cinematic.conversationCompletion,
           let levelConversation = level.conversations.first(where: { $0.name == conversation }) {
            playConversation(levelConversation: levelConversation)
        } else {
            scene.core?.gameCamera?.followedObject = player.node
            scene.core?.state.switchOn(newStatus: .inDefault)
            scene.core?.animation?.titleTransitionEffect(scene: scene) {
                self.scene.game?.controller?.enable()
                self.scene.core?.hud?.addContent()
            }
        }
    }
    
    /// Special completions on cinematic
    private func specialCinematicCompletion(cinematic: GameCinematic) {
        guard let specialCompletion = cinematic.specialCompletion else { return }
        switch specialCompletion {
        case .barrierAdding:
            scene.core?.content?.addPlayerBarrier()
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
    
    /// Returns an animation effect from the current cinematic node.
    private func cinematicObjectAnimation(node: PKObjectNode,
                                          stateIDIdentifier: GameAnimation.StateID,
                                          effect: GameCharacterCinematicActionEffect) -> SKAction {
        guard let animation = scene.core?.animation else { return SKAction.empty() }
        let spriteAnimation = animation.animate(node: node,
                                                identifier: stateIDIdentifier,
                                                filteringMode: .nearest,
                                                timeInterval: 0.1)
        
        switch true {
        case effect.repeatCount != nil:
            return SKAction.repeat(spriteAnimation, count: effect.repeatCount!)
        case effect.isRepeatingForever:
            return SKAction.repeatForever(spriteAnimation)
        default:
            return spriteAnimation
        }
    }
    
    /// Returns all animations effect of the current cinematic node.
    private func cinematicNodeEffect(node: PKObjectNode, action: CinematicAction) -> [SKAction] {
        var actions: [SKAction] = []
        
        guard let effect = action.effect else { return [] }
        guard let stateIDIdentifier = GameAnimation.StateID(rawValue: effect.stateIDIdentifier) else {
            return []
        }
        
        let objectAnimation = cinematicObjectAnimation(node: node,
                                                       stateIDIdentifier: stateIDIdentifier,
                                                       effect: effect)
        
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
        guard let objectNode = scene.core?.content?.createObject(object, at: startingCoordinate) else { return nil }
        
        objectNode.size = objectNode.size * (action.effect?.sizeGrowth ?? 1)
        objectNode.zPosition = GameConfiguration.sceneConfiguration.animationZPosition
        objectNode.alpha = 0
        
        return objectNode
    }
    
    /// Disable the current level cinematic. (To not trigger it again.)
    private func disableCinematic() {
        guard let currentLevelCinematic = scene.game?.currentLevelCinematic else { return }
        scene.game?.saves[0].passedCinematics?.append(currentLevelCinematic.name)
        scene.game?.updateSaves()
    }
    
    /// Reset the current cinematic.
    private func resetCinematic() {
        scene.game?.currentLevelCinematic = nil
        scene.game?.currentCinematic = nil
    }
}

// MARK: - Conversations

extension GameEvent {
    
    /// Play the current conversation.
    func playConversation(levelConversation: LevelConversation) {
        guard let game = scene.game else { return }
        guard game.isConversationAvailable else { return }
        
        hideButtonPopUp()
        scene.core?.hud?.removeContent()
        scene.game?.controller?.disable(isUserInteractionEnabled: true)
        scene.game?.currentLevelConversation = levelConversation
        scene.core?.state.switchOn(newStatus: .inConversation)
        scene.core?.hud?.addConversationBox()
    }
}

// MARK: - Updates

extension GameEvent {
    
    /// Updates player coordinate
    func updatePlayerCoordinate() {
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
    
    /// Dismiss the current pop up button.
    func dismissButtonPopUp() {
        guard let popUpButton = scene.childNode(withName: GameConfiguration.nodeKey.popUpButton) else {
            return
        }
        popUpButton.removeFromParent()
        scene.player?.interactionStatus = .none
        scene.game?.currentInteractiveObject = nil
    }
    
    /// Hide the current pop up button.
    func hideButtonPopUp() {
        guard let popUpButton = scene.childNode(withName: GameConfiguration.nodeKey.popUpButton) else {
            return
        }
        popUpButton.alpha = 0
    }
    
    /// Hide the current pop up button.
    func showButtonPopUp() {
        guard let popUpButton = scene.childNode(withName: GameConfiguration.nodeKey.popUpButton) else {
            return
        }
        popUpButton.alpha = 1
    }
}

// MARK: - Levels

extension GameEvent {
    
    /// Restart the current level of the game.
    func restartLevel(delayedBy seconds: Double = 0) {
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
}

// MARK: - Interactions


extension GameEvent {
    
    /// Load the next level of the game.
    func loadNextLevel() {
        scene.game?.hasTitleBeenDisplayed = false
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
    
    /// Activates a blue crystal power.
    func activateBlueCrystal() {
        guard let player = scene.player else { return }
        guard let game = scene.game else { return }
        guard let level = game.level else { return }
        scene.game?.controller?.action.disable()
        scene.core?.animation?.addObjectEffect(keyName: GameConfiguration.nodeKey.spiritRefillEffect,
                                               scene: scene,
                                               node: player.node,
                                               growth: 1.5,
                                               timeInterval: 0.1) {
            if let levelConversation = level.conversations.first(where: {
                $0.name == GameConfiguration.nodeKey.firstCrystalTakeConversation
            }) {
                self.playConversation(levelConversation: levelConversation)
            }
            self.removeEffectFromInteractiveObject()
            self.changeInteractiveObjectAppearance(image: "disabledCrystal")
            self.disableObjectInteraction()
            self.scene.player?.increaseMaxEnergy(game: game, amount: 25)
            self.scene.player?.unlockPower(game: game)
            self.scene.core?.hud?.updateEnergy()
            self.scene.game?.controller?.action.enable()
        }
    }
    
    func changeInteractiveObjectAppearance(image: String) {
        guard let currentInteractiveObject = scene.game?.currentInteractiveObject else { return }
        currentInteractiveObject.texture = SKTexture(imageNamed: image)
        currentInteractiveObject.texture?.filteringMode = .nearest
    }
    
    func disableObjectInteraction() {
        guard let currentInteractiveObject = scene.game?.currentInteractiveObject else { return }
        currentInteractiveObject.physicsBody = nil
    }
    
    func removeEffectFromInteractiveObject() {
        guard let currentInteractiveObject = scene.game?.currentInteractiveObject else { return }
        let allEffects = scene.childNodes(named: "Effect")
        let effect = allEffects.first {
            if let name = $0.name,
               let currentInteractiveObjectName = currentInteractiveObject.name {
                return name.contains(currentInteractiveObjectName)
            }
            return false
        }
        effect?.removeFromParent()
    }
}
