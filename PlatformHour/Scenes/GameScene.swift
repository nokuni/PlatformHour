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
    
    var player: Dice?
    var game: Game?
    var core: GameCore?
    
    func startGame() {
        setup(configuration: .init(gravity: GameConfiguration.worldConfiguration.gravity))
        player = Dice()
        game?.loadGame()
        game = Game.shared
        core = GameCore()
        core?.start(game: game, scene: self)
        core?.sound.playBackgroundMusic()
        core?.animation?.transitionEffect(effect: SKAction.fadeOut(withDuration: 2),
                                         isVisible: true,
                                         scene: self) {
            self.game?.controller = GameControllerManager(scene: self)
        }
    }
    
    public override func didMove(to view: SKView) {
        startGame()
        core?.gameCamera?.camera.gesture(view)
    }
    
    public override func update(_ currentTime: TimeInterval) {
        //core?.gameCamera?.followPlayer()
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
        
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}
