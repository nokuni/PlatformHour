//
//  GameScene.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 31/01/23.
//

import SpriteKit
import GameController
import PlayfulKit
import UtilityToolbox

final class GameScene: SKScene {
    
    var player: Player?
    var game: Game?
    var core: GameCore?
    
    func launch() {
        setup(configuration: .init(backgroundColor: .white, isIgnoringSiblingOrder: true))
        player = Player()
        game?.loadSave()
        game = Game.shared
        core = GameCore()
        core?.setup(scene: self)
    }
    
    override func didMove(to view: SKView) {
        launch()
        //core?.gameCamera?.camera.gesture(view)
    }
    
    override func update(_ currentTime: TimeInterval) {
        core?.gameCamera?.follow()
        core?.logic?.projectileFollowPlayer()
        core?.event?.updatePlayerCoordinate()
        //core?.event?.updatePlatformCoordinates()
    }
    
    private func bodyContacts(_ contact: SKPhysicsContact) -> (SKPhysicsBody, SKPhysicsBody) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        return (firstBody, secondBody)
    }
    
    private func didBegin(_ contact: SKPhysicsContact) {
        guard let collision = core?.collision else { return }
        let bodies = bodyContacts(contact)
        collision.all(firstBody: bodies.0, secondBody: bodies.1)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        core?.hud?.passLine()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}
