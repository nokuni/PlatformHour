//
//  GameHUD.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 05/02/23.
//

import SpriteKit
import PlayfulKit
import Utility_Toolbox
import SwiftUI

public class GameHUD {
    public init(scene: GameScene) {
        self.scene = scene
        createLayer()
        createHUD()
    }
    
    var scene: GameScene
    
    private let layer = SKShapeNode(rectOf: .screen)
    
    func createBackgroundFilter(color: UIColor = .black, alpha: CGFloat = 0.7, on node: SKNode) {
        guard let camera = scene.camera else { return }
        let filterNode = SKShapeNode(rectOf: CGSize.screen * 2)
        filterNode.strokeColor = color
        filterNode.fillColor = color
        filterNode.alpha = alpha
        filterNode.position = camera.position
        node.addChild(filterNode)
    }
    
    // MARK: - Creations
    public func createLayer() {
        layer.fillColor = .clear
        layer.strokeColor = .clear
        layer.zPosition = 1
        scene.camera?.addChild(layer)
    }
    public func createHUD() {
        createItemAmountHUD()
    }
    private func createItemAmountHUD() {
        
        guard let player = scene.player else { return }
        
        let score = SKNode()
        score.name = "Score"
        score.setScale(0.8)
        score.position = layer.cornerPosition(corner: .topLeft, node: score, padding: EdgeInsets(top: 40, leading: 40, bottom: 0, trailing: 0))
        layer.addChildSafely(score)
        
        let xLetter = SKSpriteNode(imageNamed: "xLetter")
        xLetter.texture?.filteringMode = .nearest
        xLetter.size = GameConfiguration.worldConfiguration.tileSize
        xLetter.position = CGPoint(x: GameConfiguration.worldConfiguration.tileSize.width / 2, y: 0)
        score.addChildSafely(xLetter)
        
        let number = SKSpriteNode(imageNamed: "indicator\(player.bag.count)")
        number.name = "Number"
        number.texture?.filteringMode = .nearest
        number.size = GameConfiguration.worldConfiguration.tileSize
        number.position = CGPoint(x: GameConfiguration.worldConfiguration.tileSize.width * 1.5, y: 0)
        score.addChildSafely(number)
        
        let item = SKSpriteNode(imageNamed: "hudSphere")
        item.name = "Sphere"
        item.texture?.filteringMode = .nearest
        item.size = GameConfiguration.worldConfiguration.tileSize
        item.position = .zero
        score.addChildSafely(item)
    }
    
    public func updateItemAmountHUD() {
        guard let player = scene.player else { return }
        guard let score = layer.childNode(withName: "Score") else { return }
        guard let number = score.childNode(withName: "Number") as? SKSpriteNode else { return }
        number.texture = SKTexture(imageNamed: "indicator\(player.bag.count)")
        number.texture?.filteringMode = .nearest
    }
    
    func createPauseButton() {
        
    }
    
    func createPauseScreen() {
        let pauseNode = SKNode()
        pauseNode.name = "Pause Screen"
        scene.addChild(pauseNode)
        createBackgroundFilter(on: pauseNode)
        createPauseMenu(on: pauseNode)
    }
    func removePauseScreen() {
        guard let pauseScreen = scene.childNode(withName: "Pause Screen") else { return }
        pauseScreen.removeFromParent()
    }
    
    func createPauseMenu(on node: SKNode) {
        guard let camera = scene.camera else { return }
        let menuNode = SKShapeNode(rectOf: CGSize(width: 250, height: 250))
        menuNode.fillColor = .white
        menuNode.position = camera.position
        node.addChild(menuNode)
    }
    
    func pause() { layer.isPaused = true }
    func unpause() { layer.isPaused = false }
}
