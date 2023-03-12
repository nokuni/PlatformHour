//
//  GameHUD.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 05/02/23.
//

import SpriteKit
import PlayfulKit
import Utility_Toolbox

public class GameHUD {
    public init(scene: GameScene, dimension: GameDimension) {
        self.scene = scene
        self.dimension = dimension
        createFilter()
        createItemAmountHUD()
    }
    
    var scene: GameScene
    var dimension: GameDimension
    
    let filter = SKShapeNode(rectOf: .screen)
    
    func createBackgroundFilter(color: UIColor = .black, alpha: CGFloat = 0.7, on node: SKNode) {
        guard let camera = scene.camera else { return }
        let filterNode = SKShapeNode(rectOf: CGSize.screen * 2)
        filterNode.strokeColor = color
        filterNode.fillColor = color
        filterNode.alpha = alpha
        filterNode.position = camera.position
        node.addChild(filterNode)
    }
    
    private func createFilter() {
        filter.fillColor = .clear
        filter.strokeColor = .clear
        scene.camera!.addChildSafely(filter)
    }
    
    private func createItemAmountHUD() {
        
        guard let player = scene.player else { return }
        
        let score = SKNode()
        score.name = "Score"
        score.setScale(0.8)
        score.position = filter.cornerPosition(corner: .topRight, node: score, padding: 40)
        filter.addChildSafely(score)
        
        let xLetter = SKSpriteNode(imageNamed: "xLetter")
        xLetter.texture?.filteringMode = .nearest
        xLetter.size = dimension.tileSize
        xLetter.position = CGPoint(x: -(dimension.tileSize.width * 2), y: 0)
        score.addChildSafely(xLetter)
        
        let number = SKSpriteNode(imageNamed: "indicator\(player.bag.count)")
        number.name = "Number"
        number.texture?.filteringMode = .nearest
        number.size = dimension.tileSize
        number.position = CGPoint(x: -dimension.tileSize.width, y: 0)
        score.addChildSafely(number)
        
        let item = SKSpriteNode(imageNamed: "hudSphere")
        item.texture?.filteringMode = .nearest
        item.size = dimension.tileSize
        item.position = .zero
        score.addChildSafely(item)
    }
    public func updateItemAmountHUD() {
        guard let player = scene.player else { return }
        guard let score = filter.childNode(withName: "Score") else { return }
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
}
