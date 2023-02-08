//
//  GameHUD.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 05/02/23.
//

import SpriteKit
import PlayfulKit

class GameHUD {
    init(scene: SKScene) {
        self.scene = scene
    }
    
    var scene: SKScene?
    
    func createBackgroundFilter(color: UIColor = .black, alpha: CGFloat = 0.7, on node: SKNode) {
        guard let scene = scene as? GameScene else { return }
        guard let camera = scene.camera else { return }
        let filterNode = SKShapeNode(rectOf: CGSize.screen * 2)
        filterNode.strokeColor = color
        filterNode.fillColor = color
        filterNode.alpha = alpha
        filterNode.position = camera.position
        node.addChild(filterNode)
    }
    
    func createPauseButton() {
        
    }
    
    func createPauseScreen() {
        guard let scene = scene as? GameScene else { return }
        let pauseNode = SKNode()
        pauseNode.name = "Pause Screen"
        scene.addChild(pauseNode)
        createBackgroundFilter(on: pauseNode)
        createPauseMenu(on: pauseNode)
    }
    func removePauseScreen() {
        guard let scene = scene as? GameScene else { return }
        guard let pauseScreen = scene.childNode(withName: "Pause Screen") else { return }
        pauseScreen.removeFromParent()
    }
    
    func createPauseMenu(on node: SKNode) {
        guard let scene = scene as? GameScene else { return }
        guard let camera = scene.camera else { return }
        let menuNode = SKShapeNode(rectOf: CGSize(width: 250, height: 250))
        menuNode.fillColor = .white
        menuNode.position = camera.position
        node.addChild(menuNode)
    }
}
