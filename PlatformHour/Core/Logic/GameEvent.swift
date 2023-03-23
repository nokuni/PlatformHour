//
//  GameEvent.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 14/03/23.
//

import SpriteKit
import PlayfulKit
import Utility_Toolbox

public final class GameEvent {
    
    public init(scene: GameScene) {
        self.scene = scene
    }
    
    var scene: GameScene
    
    public func dismissButtonPopUp() {
        guard let buttonPopUp = scene.childNode(withName: GameConfiguration.sceneConfigurationKey.buttonPopUp) else {
            return
        }
        buttonPopUp.removeFromParent()
        scene.player?.interactionStatus = .none
    }
    
    public func loadNextLevel() {
        scene.isUserInteractionEnabled = false
        let smoke = SKShapeNode(rectOf: scene.size * 2)
        smoke.alpha = 0
        smoke.fillColor = .white
        smoke.strokeColor = .white
        smoke.position = scene.player?.node.position ?? .zero
        scene.addChild(smoke)
        let sequence = SKAction.sequence([
            SKAction.fadeIn(withDuration: 2),
            SKAction.run { self.scene.core?.collision?.collisionLogic.quitLevel() }
        ])
        smoke.run(sequence)
    }
}
