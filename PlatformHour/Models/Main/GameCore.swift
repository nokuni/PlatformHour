//
//  GameCore.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 07/03/23.
//

import SpriteKit
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
    
    mutating public func start(game: Game?, scene: GameScene) {
        event = GameEvent(scene: scene)
        environment = GameEnvironment(scene: scene)
        collision = GameCollision(scene: scene)
        hud = GameHUD(scene: scene)
        animation = GameAnimation()
        
        guard let environment = environment else { return }
        
        logic = GameLogic(scene: scene, environment: environment)
        
        guard let animation = animation else { return }
        
        guard let logic = logic else { return }
        
        gameCamera = GameCamera(scene: scene, environment: environment)
        content = GameContent(scene: scene, environment: environment, animation: animation, logic: logic)
    }
    
    public func animateLaunch(game: Game?, scene: GameScene, player: Dice?) {
        scene.isUserInteractionEnabled = false
        let smoke = SKShapeNode(rectOf: scene.size * 2)
        smoke.fillColor = .white
        smoke.strokeColor = .white
        smoke.position = player?.node.position ?? .zero
        scene.addChild(smoke)
        let sequence = SKAction.sequence([
            SKAction.fadeOut(withDuration: 2),
            SKAction.removeFromParent(),
            SKAction.run {
                scene.isUserInteractionEnabled = true
                game?.controller = GameControllerManager(scene: scene)
            }
        ])
        smoke.run(sequence)
    }
}
