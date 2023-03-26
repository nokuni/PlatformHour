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
    private let actionSequence = SKNode()
    
    public var diceActions: [SKSpriteNode] {
        let actionNodes = actionSequence.childNodes(named: "Dice Action")
        let actions = actionNodes.compactMap { $0 as? SKSpriteNode }
        return actions
    }
    
    private var actionSequenceHUDConstraints: EdgeInsets {
        let leading = (layer.frame.width / 2) - (GameConfiguration.worldConfiguration.tileSize.width * 3) + (GameConfiguration.worldConfiguration.tileSize.width / 2)
        let constraints = EdgeInsets(top: 40, leading: leading, bottom: 0, trailing: 0)
        return constraints
    }
    
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
        layer.zPosition = GameConfiguration.worldConfiguration.hudZPosition
        scene.camera?.addChild(layer)
    }
    public func createHUD() {
        createItemAmountHUD()
        createActionSequenceHUD()
    }
    public func createActionSequenceHUD() {
        
        actionSequence.name = "Action Sequence"
        layer.addChildSafely(actionSequence)
        
        let sequenceImages = ["sequenceSpace0", "sequenceSpace1", "sequenceSpace1", "sequenceSpace1", "sequenceSpace1", "sequenceSpace2"]
        var sequenceHUD: [SKSpriteNode] = []
        
        for image in sequenceImages {
            let hud = SKSpriteNode(imageNamed: image)
            hud.texture?.filteringMode = .nearest
            hud.size = GameConfiguration.worldConfiguration.tileSize
            sequenceHUD.append(hud)
        }
        
        let sequencePosition = layer.cornerPosition(corner: .topLeft, node: actionSequence, padding: actionSequenceHUDConstraints)
        
        GameConfiguration.assemblyManager.createSpriteList(of: sequenceHUD, at: sequencePosition, in: layer, axes: .horizontal, adjustement: .leading, spacing: 1)
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
        
        player.bag.count.intoSprites(with: "indicator",
                                     filteringMode: .nearest,
                                     spacing: 0.5,
                                     of: GameConfiguration.worldConfiguration.tileSize,
                                     at: CGPoint(x: GameConfiguration.worldConfiguration.tileSize.width * 1.5,
                                                 y: 0),
                                     on: score)
        
        let item = SKSpriteNode(imageNamed: "hudOrb")
        item.name = "Orb"
        item.texture?.filteringMode = .nearest
        item.size = GameConfiguration.worldConfiguration.tileSize
        item.position = .zero
        score.addChildSafely(item)
    }
    
    public func addDiceActionsHUD() {
        guard let player = scene.player else { return }
        
        var actions: [SKSpriteNode] = []
        
        for index in 0..<player.currentRoll.rawValue {
            let action = SKSpriteNode(imageNamed: "diceAction")
            action.name = "Dice Action \(index)"
            action.texture?.filteringMode = .nearest
            action.zPosition = GameConfiguration.worldConfiguration.elementHUDZPosition
            action.size = GameConfiguration.worldConfiguration.tileSize
            let animation = SKAction.sequence([
                SKAction.scale(by: 1.1, duration: 0.1),
                SKAction.scale(by: 0.9, duration: 0.1),
                SKAction.scale(by: 1, duration: 0.1)
            ])
            action.run(animation)
            
            actions.append(action)
        }
        
        let position = layer.cornerPosition(corner: .topLeft, node: actionSequence, padding: actionSequenceHUDConstraints)
        
        let parameter = AssemblyManager.Parameter(axes: .horizontal, adjustement: .leading, horizontalSpacing: 1, verticalSpacing: 1, columns: 6)
        
        GameConfiguration.assemblyManager.createSpriteCollectionWithDelay(of: actions, at: position, in: actionSequence, parameter: parameter, delay: 0.1, actionOnGoing: nil, actionOnEnd: {
            self.scene.core?.logic?.enableControls()
        })
    }
    
    // MARK: - Updates
    public func updateScore() {
        let score = layer.childNode(withName: "Score")
        score?.removeFromParent()
        createItemAmountHUD()
    }
    
    public func removeDiceActions() {
        diceActions.forEach { $0.removeFromParent() }
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
