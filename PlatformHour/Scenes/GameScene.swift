//
//  GameScene.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 31/01/23.
//

import SpriteKit
import GameController
import PlayfulKit
import Utility_Toolbox

public final class GameScene: SKScene {
    
    public var player: Player?
    public var game: Game?
    public var core: GameCore?
    
    public func launch() {
        setup(configuration: .init(backgroundColor: .white, isIgnoringSiblingOrder: true))
        player = Player()
        game?.loadSave()
        game = Game.shared
        core = GameCore()
        core?.setup(scene: self)
    }
    
    public override func didMove(to view: SKView) {
        launch()
        //core?.gameCamera?.camera.gesture(view)
    }
    
    public override func update(_ currentTime: TimeInterval) {
        core?.gameCamera?.follow()
        core?.logic?.projectileFollowPlayer()
        core?.event?.updatePlayerCoordinate()
        //core?.event?.updatePlatformCoordinates()
        core?.event?.triggerPlayerDeathFall()
    }
    
    public func didBegin(_ contact: SKPhysicsContact) {
        
        guard let collision = core?.collision else { return }
        
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
        core?.hud?.passLine()
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}
