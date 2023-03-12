//
//  GameCore.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 07/03/23.
//

import SpriteKit
import Utility_Toolbox

public struct GameCore {
    public init(state: GameState? = nil,
                hud: GameHUD? = nil,
                sound: GameSound? = nil,
                dimension: GameDimension? = nil,
                animation: GameAnimation? = nil,
                environment: GameEnvironment? = nil,
                logic: GameLogic? = nil,
                collision: GameCollision? = nil,
                gameCamera: GameCamera? = nil,
                content: GameContent? = nil) {
        self.state = state
        self.hud = hud
        self.sound = sound
        self.dimension = dimension
        self.animation = animation
        self.environment = environment
        self.logic = logic
        self.collision = collision
        self.gameCamera = gameCamera
        self.content = content
    }
    
    public var state: GameState?
    public var hud: GameHUD?
    public var sound: GameSound?
    public var dimension: GameDimension?
    public var animation: GameAnimation?
    public var environment: GameEnvironment?
    public var logic: GameLogic?
    public var collision: GameCollision?
    public var gameCamera: GameCamera?
    public var content: GameContent?
    
    mutating public func start(game: Game?, scene: GameScene) {
        
        state = GameState(scene: scene)
        sound = GameSound(scene: scene)
        dimension = GameDimension(scene: scene)
        logic = GameLogic(scene: scene)
        animation = GameAnimation(scene: scene)
        collision = GameCollision(scene: scene)
        
        guard let dimension = dimension else { return }
        
        environment = GameEnvironment(scene: scene, dimension: dimension)
        
        guard let environment = environment else { return }
        
        gameCamera = GameCamera(scene: scene, environment: environment)
        
        content = GameContent(scene: scene, dimension: dimension, environment: environment)
        
        hud = GameHUD(scene: scene, dimension: dimension)
        
        //        guard let content = content else { return }
        //        
        //        game?.controller = GameControllerManager(scene: scene, state: state, dimension: dimension, environment: environment, content: content)
    }
    
    public func animateLaunch(game: Game?, scene: GameScene, player: Player?) {
        let smoke = SKShapeNode(rectOf: scene.size * 2)
        smoke.fillColor = .white
        smoke.strokeColor = .white
        smoke.position = player?.node.position ?? .zero
        scene.addChild(smoke)
        let sequence = SKAction.sequence([
            SKAction.fadeOut(withDuration: 2),
            SKAction.removeFromParent(),
            SKAction.run {
                player?.node.isPaused = false
                game?.controller = GameControllerManager(scene: scene, state: self.state!, dimension: self.dimension!, environment: self.environment!, content: self.content!)
            }
        ])
        smoke.run(sequence)
    }
}
