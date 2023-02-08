//
//  GameScene.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 31/01/23.
//

import SpriteKit
import GameController
import PlayfulKit

final public class GameScene: SKScene, ObservableObject, SKPhysicsContactDelegate {
    
    @Published var player = Player()
    
    var dimension: GameDimension?
    var gameCamera: GameCamera?
    var animation: GameAnimation?
    var collision: GameCollision?
    var controller: GameControllerManager?
    var state: GameState?
    var environment: GameEnvironment?
    var content: GameContent?
    var logic: GameLogic?
    var sound: GameSound?
    var hud: GameHUD?
    
    func startGame() {
        size = CGSize.screen
        physicsWorld.gravity = CGVector(dx: 0, dy: -10)
        physicsWorld.contactDelegate = self
        
        print("Game started")
        
        dimension = GameDimension(scene: self)
        
        gameCamera = GameCamera(scene: self)
        animation = GameAnimation(scene: self)
        collision = GameCollision(scene: self)
        controller = GameControllerManager(scene: self)
        state = GameState(scene: self)
        
        environment = GameEnvironment(scene: self)
        content = GameContent(scene: self)
        logic = GameLogic(scene: self)
        sound = GameSound(scene: self)
        hud = GameHUD(scene: self)
    }
    
    public override func didMove(to view: SKView) {
        startGame()
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
        
        collision.hitObject(
            GameCollision.NodeBody(body: firstBody, bitmaskCategory: collision.playerMask),
            with: GameCollision.NodeBody(body: secondBody, bitmaskCategory: collision.objectMask)
        )
        
        collision.landOnGround(
            GameCollision.NodeBody(body: firstBody, bitmaskCategory: collision.playerMask),
            with: GameCollision.NodeBody(body: secondBody, bitmaskCategory: collision.wallMask)
        )
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        guard !touchedNodes.isEmpty else { return }
        
        for touchedNode in touchedNodes {
            if let name = touchedNode.name {
                
                if let direction = GameControllerManager.Direction.allCases.first(where: { $0.rawValue == name }) {
                    controller?.virtual?.touchDirectionalPad(direction)
                }
                
                if let button = GameControllerManager.Button.allCases.first(where: { $0.rawValue == name }) {
                    controller?.virtual?.touchButton(button)
                }
            }
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        controller?.action?.stopMovement()
    }
    
}
