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
        guard let buttonPopUp = scene.childNode(withName: GameConfiguration.sceneConfigurationKey.buttonPopUp) else {
            return
        }
        buttonPopUp.removeFromParent()
    }
    
    public func dismissStatueRequirementPopUp() {
        guard let requirementPopUp = scene.childNode(withName: GameConfiguration.sceneConfigurationKey.requirementPopUp) else {
            return
        }
        requirementPopUp.removeFromParent()
        scene.player?.interactionStatus = .none
    }
    
    private func updateStatueRequirementPopUp() {
        
        guard let statue = scene.game?.level?.statue else { return }
        
        guard let requirementPopUp = scene.childNode(withName: GameConfiguration.sceneConfigurationKey.requirementPopUp) else {
            return
        }
        
        guard let number = requirementPopUp.childNode(withName: GameConfiguration.sceneConfigurationKey.number) as? SKSpriteNode else {
            return
        }
        
        number.texture = SKTexture(imageNamed: "\(GameConfiguration.imageConfigurationKey.indicator)\(statue.requirement.count)")
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
    }
    
    func putItemOnStatue() {
        guard let statue = scene.game?.level?.statue else { return }
        guard let environment = scene.core?.environment else { return }
        
        if let statuePosition = environment.map.tilePosition(from: statue.coordinates[0].coordinate) {
            
            let position = CGPoint(x: statuePosition.x + (GameConfiguration.worldConfiguration.tileSize.width * 0.5), y: statuePosition.y - GameConfiguration.worldConfiguration.tileSize.height)
            
            let item = SKSpriteNode(imageNamed: "sphereStatue")
            item.texture?.filteringMode = .nearest
            item.size = GameConfiguration.worldConfiguration.tileSize
            item.position = scene.player?.node.position ?? .zero
            environment.map.addChildSafely(item)
            
            let sequence = SKAction.sequence([
                SKAction.run {
                    self.scene.isUserInteractionEnabled = false
                },
                SKAction.move(to: position, duration: 0.5)
            ])
            
            SKAction.start(animation: sequence, node: item) { self.showExit() }
        }
    }
    
    func showExit() {
        guard let environment = scene.core?.environment else { return }
        guard let logic = scene.core?.logic else { return }
        guard let coordinatePosition = environment.map.tilePosition(from: Coordinate(x: 13, y: 39)) else { return }
        guard let gameCamera = scene.core?.gameCamera else { return }
        let exitPosition = CGPoint(x: coordinatePosition.x, y: coordinatePosition.y + gameCamera.adjustement)
        let openExitDoor = SKAction.sequence([
            SKAction.run { logic.openExitDoor() },
            SKAction.wait(forDuration: 2)
        ])
        let showcase = CameraManager.Showcase(targetPoint: exitPosition, showAction: openExitDoor) {
            gameCamera.camera.move(to: gameCamera.playerPosition)
            self.scene.player?.node.isPaused = false
            self.scene.isUserInteractionEnabled = true
        }
        
        if scene.game!.level!.statue.requirement.isEmpty {
            gameCamera.camera.showcase(showcase)
        } else {
            scene.isUserInteractionEnabled = true
        }
    }
}
