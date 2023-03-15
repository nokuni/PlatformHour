//
//  GameEvent.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 14/03/23.
//

import SpriteKit
import PlayfulKit

public final class GameEvent {
    
    public init(scene: GameScene) {
        self.scene = scene
    }
    
    var scene: GameScene
    
    public func dismissButtonPopUp() {
        guard let buttonPopUp = scene.childNode(withName: GameApp.sceneConfigurationKey.buttonPopUp) else {
            return
        }
        buttonPopUp.removeFromParent()
    }
    
    public func dismissStatueRequirementPopUp() {
        guard let requirementPopUp = scene.childNode(withName: GameApp.sceneConfigurationKey.requirementPopUp) else {
            return
        }
        requirementPopUp.removeFromParent()
        scene.player?.interactionStatus = .none
    }
    
    private func updateStatueRequirementPopUp() {
        
        guard let statue = scene.game?.level?.statue else { return }
        
        guard let requirementPopUp = scene.childNode(withName: GameApp.sceneConfigurationKey.requirementPopUp) else {
            return
        }
        
        guard let number = requirementPopUp.childNode(withName: GameApp.sceneConfigurationKey.number) as? SKSpriteNode else {
            return
        }
        
        number.texture = SKTexture(imageNamed: "\(GameApp.imageConfigurationKey.indicator)\(statue.requirement.count)")
        number.texture?.filteringMode = .nearest
    }
    
    func giveItemToStatue() {
        scene.game?.level?.statue.requirement.removeLast()
        scene.player?.bag.removeLast()
        scene.core?.hud?.updateItemAmountHUD()
        updateStatueRequirementPopUp()
        if scene.player!.bag.isEmpty { dismissButtonPopUp() }
        if scene.game!.level!.statue.requirement.isEmpty { dismissStatueRequirementPopUp() }
        putItemOnStatue()
        showExit()
    }
    
    func putItemOnStatue() {
        guard let statue = scene.game?.level?.statue else { return }
        guard let environment = scene.core?.environment else { return }
        
        if let statuePosition = environment.map.tilePosition(from: statue.coordinates[0].coordinate) {
            
            let position = CGPoint(x: statuePosition.x + (GameApp.worldConfiguration.tileSize.width * 0.5), y: statuePosition.y - GameApp.worldConfiguration.tileSize.height)
            
            let item = SKSpriteNode(imageNamed: "sphereStatue")
            item.texture?.filteringMode = .nearest
            item.size = GameApp.worldConfiguration.tileSize
            item.position = scene.player?.node.position ?? .zero
            environment.map.addChildSafely(item)
            
            let moveAction = SKAction.move(to: position, duration: 0.5)
            
            item.run(moveAction)
        }
    }
    
    func showExit() {
        guard let position = scene.core?.environment?.map.tilePosition(from: Coordinate(x: 13, y: 30)) else { return }
        let showcase = CameraManager.Showcase(targetPoint: position) {
            self.scene.core?.gameCamera?.camera.move(to: self.scene.core?.gameCamera?.playerPosition ?? .zero)
        }
        scene.core?.gameCamera?.camera.showcase(showcase)
    }
}
