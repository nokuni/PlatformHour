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
    init(state: GameState = GameState(),
         animation: GameAnimation? = nil,
         sound: GameSound = GameSound(),
         event: GameEvent? = nil,
         hud: GameHUD? = nil,
         environment: GameEnvironment? = nil,
         logic: GameLogic? = nil,
         collision: GameCollision? = nil,
         gameCamera: GameCamera? = nil,
         content: GameContent? = nil) {
        self.state = state
        self.animation = animation
        self.sound = sound
        self.event = event
        self.hud = hud
        self.environment = environment
        self.logic = logic
        self.collision = collision
        self.gameCamera = gameCamera
        self.content = content
    }
    
    var state: GameState
    var animation: GameAnimation?
    var sound: GameSound
    var event: GameEvent?
    var hud: GameHUD?
    var environment: GameEnvironment?
    var logic: GameLogic?
    var collision: GameCollision?
    var gameCamera: GameCamera?
    var content: GameContent?
}

extension GameCore {
    
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
    
    /// Returns the starting level cinematic.
    private func startingCinematic(scene: GameScene) -> LevelCinematic? {
        let cinematic = scene.game?.level?.cinematics.first(where: { $0.category == .onStart })
        return cinematic
    }
    
    /// Launchs the starting level cinematic.
    private func launchStartingCinematic(scene: GameScene) {
        if let cinematic = startingCinematic(scene: scene) {
            scene.game?.controller?.disable()
            scene.core?.event?.startCinematic(levelCinematic: cinematic)
        } else {
            scene.game?.controller?.enable()
            scene.core?.hud?.addContent()
        }
    }
    
    /// Start the scene transition.
    private func start(scene: GameScene) {
        animation?.sceneTransitionEffect(scene: scene,
                                         effectAction: SKAction.fadeOut(withDuration: 2),
                                         isFadeIn: true,
                                         isShowingTitle: startingCinematic(scene: scene) == nil) {
            self.launchStartingCinematic(scene: scene)
        }
    }
}
