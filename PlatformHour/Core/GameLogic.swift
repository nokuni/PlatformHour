//
//  GameLogic.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 05/02/23.
//

import SpriteKit
import PlayfulKit

final public class GameLogic {
    
    init(scene: SKScene) {
        self.scene = scene
    }
    
    var scene: SKScene?
    @Published var isExitOpen: Bool = false
    
    func openExit() {
        guard let scene = scene as? GameScene else { return }
        guard let animation = scene.animation else { return }
        guard let exitPortal = scene.content?.all?.childNode(withName: "Exit Portal") as? SKSpriteNode else { return }
        let lockBoxesCount = scene.content?.all?.children.getCount(named: "lockBox")
        if lockBoxesCount == 6 {
            isExitOpen = true
            let counts = Array(0..<3).reversed()
            let images = counts.map { "greenPortal\($0)" }
            let portalAnimation = animation.kit.spriteAnimation(images: images, filteringMode: .nearest, timePerFrame: 0.05)
            let exitPortalAnimation = SKAction.repeatForever(portalAnimation)
            exitPortal.run(exitPortalAnimation)
        }
    }
    
    func exitLevel() {
        guard let scene = scene as? GameScene else { return }
        guard let dimension = scene.dimension else { return }
        if isExitOpen {
            let transition = SKTransition.fade(with: .white, duration: 3)
            let newScene = GameScene()
            let sequence = SKAction.sequence([
                SKAction.run {
                    scene.animation?.spark(at: CGPoint(x: scene.player.node.position.x, y: scene.player.node.position.y - dimension.tileSize.height * 0.3), count: 2)
                    scene.player.node.removeFromParent()
                },
                SKAction.wait(forDuration: 1),
                SKAction.run {
                    self.scene?.view?.presentScene(newScene, transition: transition)
                }
            ])
            scene.run(sequence)
        }
    }
    
    func lockDiceBox(_ object: SKSpriteNode) {
        guard let scene = scene as? GameScene else { return }
        if let objectName = object.name,
           let number = objectName.extractedNumber {
            let isCorrectHit = (number + 1) == scene.player.currentRoll.rawValue
            let isLocked = object.texture?.name == "lockBox"
            if isCorrectHit && !isLocked {
                scene.animation?.spark(at: object.position)
                object.run(SKAction.setTexture(SKTexture(imageNamed: "lockBox"), with: .nearest))
                object.name = "lockBox"
                scene.logic?.openExit()
            }
        }
    }
}
