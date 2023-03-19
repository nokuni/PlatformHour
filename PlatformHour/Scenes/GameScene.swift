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

final public class GameScene: SKScene {
    
    var player: Dice?
    var game: Game?
    var core: GameCore?
    
    func startGame() {
        setup(configuration: .init(gravity: GameConfiguration.worldConfiguration.gravity))
        player = Dice()
        game = Game()
        core = GameCore()
        core?.start(game: game, scene: self)
        core?.animateLaunch(game: game, scene: self, player: player)
    }
    
    public override func didMove(to view: SKView) {
        startGame()
        core?.gameCamera?.camera.gesture(view)
    }
    
    public override func update(_ currentTime: TimeInterval) {
//        core?.gameCamera?.followPlayer()
//        game?.controller?.action.projectileFollowPlayer()
        core?.logic?.updatePlayerCoordinate()
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
        
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}
