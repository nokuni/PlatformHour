//
//  GameCore.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 07/03/23.
//

import SpriteKit
import PlayfulKit
import Utility_Toolbox

struct GameCore {
    var state: GameState = GameState()
    var animation: GameAnimation?
    var sound: GameSound = GameSound()
    var event: GameEvent?
    var hud: GameHUD?
    var environment: GameEnvironment?
    var logic: GameLogic?
    var collision: GameCollision?
    var gameCamera: GameCamera?
    var content: GameContent?
}

// MARK: - Main

extension GameCore {
    
    /// Start the scene transition.
    private func start(scene: GameScene) {
        animation?.sceneTransitionEffect(scene: scene,
                                         effectAction: SKAction.fadeOut(withDuration: 2),
                                         isFadeIn: true,
                                         isShowingTitle: isShowingLevelTitle(scene: scene)) {
            self.launchStartingCinematic(scene: scene)
            self.launchStartingConversation(scene: scene)
//            self.startPlaying(scene: scene)
        }
    }
    
    private func isShowingLevelTitle(scene: GameScene) -> Bool {
        guard let game = scene.game else { return false }
        return startingCinematic(scene: scene) == nil &&
        startingConversation(scene: scene) == nil &&
        !game.hasTitleBeenDisplayed
    }
    
    /// Setup the scene.
    mutating func setup(scene: GameScene) {
        event = GameEvent(scene: scene)
        environment = GameEnvironment(scene: scene)
        collision = GameCollision(scene: scene)
        hud = GameHUD(scene: scene)
        animation = GameAnimation()
        
        guard let environment = environment else { return }
        
        logic = GameLogic(scene: scene, environment: environment)
        
        guard let animation = animation else { return }
        
        guard let logic = logic else { return }
        
        content = GameContent(scene: scene, environment: environment, animation: animation, logic: logic)
        gameCamera = GameCamera(scene: scene, environment: environment)
        
        playBackgroundSound(scene: scene)
        
        hud?.removeContent()
        
        setupControllers(scene: scene)
        
        scene.game?.controller?.disable()
        
        start(scene: scene)
    }
    
    /// Play the level background sound on the scene.
    private func playBackgroundSound(scene: GameScene) {
        sound.playBackgroundMusics(scene: scene)
    }
    
    /// Instantiate the game controllers on the scene.
    func setupControllers(scene: GameScene) {
        guard scene.game?.controller == nil else { return }
        scene.game?.controller = GameControllerManager(scene: scene, state: state)
    }
    
    private func startPlaying(scene: GameScene) {
        guard !isShowingLevelTitle(scene: scene) else { return }
        scene.game?.controller?.enable()
        scene.core?.hud?.addContent()
    }
}

// MARK: - Cinematics

extension GameCore {
    
    /// Returns the starting level cinematic.
    private func startingCinematic(scene: GameScene) -> LevelCinematic? {
        let cinematic = scene.game?.level?.cinematics.first(where: { $0.category == .onStart })
        return cinematic
    }
    
    /// Launchs the starting level cinematic.
    private func launchStartingCinematic(scene: GameScene) {
        guard let game = scene.game else { return }
        
        guard startingConversation(scene: scene) == nil else { return }
        
        guard let cinematic = startingCinematic(scene: scene) else {
            scene.game?.controller?.enable()
            scene.core?.hud?.addContent()
            return
        }
        
        if game.isCinematicAvailable {
            scene.game?.controller?.disable()
            scene.core?.event?.startCinematic(levelCinematic: cinematic)
        } else {
            scene.game?.controller?.enable()
            scene.core?.hud?.addContent()
        }
    }
}

// MARK: - Conversations

extension GameCore {
    
    /// Returns the starting level cinematic.
    private func startingConversation(scene: GameScene) -> LevelConversation? {
        let conversation = scene.game?.level?.conversations.first(where: { $0.category == .onStart })
        return conversation
    }
    
    /// Launchs the starting level cinematic.
    private func launchStartingConversation(scene: GameScene) {
        guard let game = scene.game else { return }
        
        guard startingCinematic(scene: scene) == nil else { return }
        
        guard let levelConversation = startingConversation(scene: scene) else {
            scene.game?.controller?.enable()
            scene.core?.hud?.addContent()
            return
        }
        
        if game.isConversationAvailable {
            scene.game?.controller?.disable()
            scene.core?.event?.playConversation(levelConversation: levelConversation)
        } else {
            scene.game?.controller?.enable()
            scene.core?.hud?.addContent()
        }
    }
}
