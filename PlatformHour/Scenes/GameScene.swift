//
//  GameScene.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 31/01/23.
//

import SpriteKit
import GameController
import PlayfulKit

final public class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var game = Game()
    var player = Player()
    
    var dimension: GameDimension?
    var gameCamera: GameCamera?
    var animation: GameAnimation?
    var collision: GameCollision?
    var state: GameState?
    var environment: GameEnvironment?
    var content: GameContent?
    var logic: GameLogic?
    var sound: GameSound?
    var hud: GameHUD?
    
    func startGame() {
        setup(gravity: GameCore.gravity)
        physicsWorld.contactDelegate = self
        
        print("Game started")
        
        state = GameState(scene: self)
        hud = GameHUD(scene: self)
        sound = GameSound(scene: self)
        dimension = GameDimension(scene: self)
        
        animation = GameAnimation(scene: self, dimension: dimension!)
        
        logic = GameLogic(scene: self, animation: animation!)
        
        collision = GameCollision(scene: self, game: game, animation: animation!, logic: logic!)
        
        environment = GameEnvironment(scene: self, dimension: dimension!, animation: animation!)
        
        gameCamera = GameCamera(scene: self, environment: environment!)
        
        content = GameContent(scene: self, dimension: dimension!, environment: environment!, animation: animation!)
        
        game.controller = GameControllerManager(scene: self, state: state!, dimension: dimension!, environment: environment!, content: content!)
    }
    
    public override func didMove(to view: SKView) {
        startGame()
        //cameraGesture(view)
    }
    
    public override func update(_ currentTime: TimeInterval) {
        gameCamera?.followPlayer()
    }
    
    public func didBegin(_ contact: SKPhysicsContact) {
        
        guard let collision = collision else { return }
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        collision.all(firstBody: firstBody, secondBody: secondBody)
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        guard !touchedNodes.isEmpty else { return }
        
        for touchedNode in touchedNodes {
            if let name = touchedNode.name {
                
                if let direction = ActionLogic.Direction.allCases.first(where: { $0.rawValue == name }) {
                    game.controller?.virtualController.touchDirectionalPad(direction)
                }
                
                if let button = GameControllerManager.Button.allCases.first(where: { $0.rawValue == name }) {
                    game.controller?.virtualController.touchButton(button)
                }
            }
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        game.controller?.action.stopMovement()
        game.controller?.virtualController.hasPressedAnyInput = false
    }
    
}
