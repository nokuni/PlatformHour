//
//  GameCore.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 07/03/23.
//

import SpriteKit
import PlayfulKit
import Utility_Toolbox

public struct GameCore {
    public init(state: GameState = GameState(),
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
    
    public var state: GameState
    public var animation: GameAnimation?
    public var sound: GameSound
    public var event: GameEvent?
    public var hud: GameHUD?
    public var environment: GameEnvironment?
    public var logic: GameLogic?
    public var collision: GameCollision?
    public var gameCamera: GameCamera?
    public var content: GameContent?
}

public extension GameCore {
    
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
        
        start(scene: scene)
    }
    
    /// Play the level background sound on the scene.
    private func playBackgroundSound(scene: GameScene) {
        sound.playBackgroundMusics(scene: scene)
    }
    
    /// Instantiate the game controllers on the scene.
    private func setupControllers(scene: GameScene) {
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
            scene.core?.event?.playCinematic(cinematic: cinematic)
            hideHUD(scene: scene)
        }
    }
    
    /// Hide the visible HUD elements on the screen.
    private func hideHUD(scene: GameScene) {
        hud?.removeContent()
        guard let controllerManager = scene.game?.controller?.manager else { return }
        let isVirtualControllerAvailable = !controllerManager.virtualControllerElements.isEmpty
        if isVirtualControllerAvailable { scene.game?.controller?.hideVirtualController() }
    }
    
    /// Start the scene transition.
    private func start(scene: GameScene) {
        hideHUD(scene: scene)
        animation?.sceneTransitionEffect(scene: scene,
                                         effectAction: SKAction.fadeOut(withDuration: 2),
                                         isFadeIn: true,
                                         isShowingTitle: startingCinematic(scene: scene) == nil) {
            self.setupControllers(scene: scene)
            self.launchStartingCinematic(scene: scene)
        }
    }
}
