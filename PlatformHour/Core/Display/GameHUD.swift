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
        generateLayer()
        generateContentHUD()
    }
    
    var scene: GameScene
    
    private let layer = SKShapeNode(rectOf: .screen)
    private let actionSequence = SKNode()
    
    public var actionSquares: [SKSpriteNode] {
        let actionNodes = actionSequence.childNodes(named: "Action Square")
        let actions = actionNodes.compactMap { $0 as? SKSpriteNode }
        return actions
    }
    
    private var actionSequenceHUDConstraints: EdgeInsets {
        let leading = (layer.frame.width / 2) - (GameConfiguration.worldConfiguration.tileSize.width * 3) + (GameConfiguration.worldConfiguration.tileSize.width / 2)
        let constraints = EdgeInsets(top: 40, leading: leading, bottom: 0, trailing: 0)
        return constraints
    }
    
    // MARK: - Generations
    
    /// Generate the HUD layer on the scene.
    public func generateLayer() {
        layer.fillColor = .clear
        layer.strokeColor = .clear
        layer.zPosition = GameConfiguration.sceneConfiguration.hudZPosition
        scene.camera?.addChild(layer)
    }
    
    /// Generate the content on the HUD layer.
    public func generateContentHUD() {
        generateGemScore()
        generateActionSequenceBar()
    }
    
    /// Generate the action sequence bar on the HUD.
    public func generateActionSequenceBar() {
        
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
        
        let sequencePosition = layer.cornerPosition(corner: .topLeft, padding: actionSequenceHUDConstraints)
        
        GameConfiguration.assemblyManager.createNodeList(of: sequenceHUD, at: sequencePosition, in: layer, axes: .horizontal, adjustement: .leading, spacing: 1)
    }
    
    /// Generate the gem score on the HUD.
    private func generateGemScore() {
        
        guard let player = scene.player else { return }
        
        let score = SKNode()
        score.name = "Score"
        score.setScale(0.8)
        score.position = layer.cornerPosition(corner: .topLeft, padding: EdgeInsets(top: 40, leading: 40, bottom: 0, trailing: 0))
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
        
        let item = SKSpriteNode(imageNamed: "hudGem")
        item.name = "Orb"
        item.texture?.filteringMode = .nearest
        item.size = GameConfiguration.worldConfiguration.tileSize
        item.position = .zero
        score.addChildSafely(item)
    }
    
    /// Add an action square on the action sequence bar.
    public func addActionSquaresHUD() {
        guard let player = scene.player else { return }
        
        var actions: [SKSpriteNode] = []
        
        for index in 0..<player.currentRoll.rawValue {
            let action = SKSpriteNode(imageNamed: GameConfiguration.imageKey.actionSquare)
            action.name = "Action Square \(index)"
            action.texture?.filteringMode = .nearest
            action.zPosition = GameConfiguration.sceneConfiguration.elementHUDZPosition
            action.size = GameConfiguration.worldConfiguration.tileSize
            let animation = SKAction.sequence([
                SKAction.scale(by: 1.1, duration: 0.1),
                SKAction.scale(by: 0.9, duration: 0.1),
                SKAction.scale(by: 1, duration: 0.1)
            ])
            action.run(animation)
            
            actions.append(action)
        }
        
        let position = layer.cornerPosition(corner: .topLeft, padding: actionSequenceHUDConstraints)
        
        let parameter = AssemblyManager.Parameter(axes: .horizontal, adjustement: .leading, horizontalSpacing: 1, verticalSpacing: 1, columns: 6)
        
        GameConfiguration.assemblyManager.createNodeCollectionWithDelay(of: actions, at: position, in: actionSequence, parameter: parameter, delay: 0.1, actionOnGoing: nil, actionOnEnd: {
            self.scene.core?.logic?.enableControls()
        })
    }
    
    /// Generate a filter over the HUD.
    func generateFilter(color: UIColor = .black, alpha: CGFloat = 0.7, on node: SKNode) {
        guard let camera = scene.camera else { return }
        let filterNode = SKShapeNode(rectOf: CGSize.screen * 2)
        filterNode.strokeColor = color
        filterNode.fillColor = color
        filterNode.alpha = alpha
        filterNode.zPosition = GameConfiguration.sceneConfiguration.overOverlayZPosition
        filterNode.position = camera.position
        node.addChild(filterNode)
    }
    
    // MARK: - Dialog Box
    
    /// Generate the dialog box.
    public func generateDialogBox() {
        let dialogBox = dialogBox
        
        layer.addChild(dialogBox)
        
        addDialogArrow(node: dialogBox)
        
        guard let levelDialog = scene.game?.currentLevelDialog else { return }
        guard let dialogData = GameDialog.get(levelDialog.dialog) else { return }
        
        if scene.game?.currentDialog == nil { scene.game?.currentDialog = dialogData }
        
        guard let currentDialog = scene.game?.currentDialog else { return }
        
        guard let dialog = scene.game?.currentDialog else { return }
        
        let conversation = currentDialog.conversation[dialog.currentDialogIndex]
        
        guard let character = GameCharacter.get(conversation.character) else { return }
        
        addDialogCharacter(conversation, gameCharacter: character, node: dialogBox)
        
        let lineIndex = currentDialog.conversation[dialog.currentDialogIndex].currentLineIndex
        let text = currentDialog.conversation[dialog.currentDialogIndex].lines[lineIndex]
        
        addDialogText(text, node: dialogBox)
    }
    
    /// Pass the current dialog.
    public func passDialog() {
        guard let dialogBox = layer.childNode(withName: "Dialog Box") else { return }
        guard let dialogText = dialogBox.childNode(withName: "Dialog Text") as? PKTypewriterNode else { return }
        dialogText.hasFinished() ? displayNextLine() : speedUpDialog()
    }
    
    /// Display the next line of a dialog.
    public func displayNextLine() {
        guard let dialogBox = layer.childNode(withName: "Dialog Box") else { return }
        dialogBox.removeFromParent()
        
        guard let index = scene.game?.currentDialog?.currentDialogIndex else { return }
        scene.game?.currentDialog?.conversation[index].moveOnNextLine()
        
        guard let isEndOfLine = scene.game?.currentDialog?.conversation[index].isEndOfLine else { return }
        
        if !isEndOfLine { generateDialogBox() } else { displayNextDialog() }
    }
    
    /// Display the next dialog.
    private func displayNextDialog() {
        scene.game?.currentDialog?.moveOnNextDialog()
        guard let isEndOfDialog = scene.game?.currentDialog?.isEndOfDialog else { return }
        if !isEndOfDialog { generateDialogBox() } else { endDialog() }
    }
    
    /// Returns a dialog box.
    private var dialogBox: SKSpriteNode {
        let dialogBoxTexture = SKTexture(imageNamed: "dialogBox")
        dialogBoxTexture.filteringMode = .nearest
        let dialogBoxTextureSize = dialogBoxTexture.size()
        
        let position = layer.cornerPosition(corner: .bottomLeft, padding: EdgeInsets(top: 0, leading: CGSize.screen.width * 0.5, bottom: 100, trailing: 0))
        
        let dialogBox = SKSpriteNode()
        dialogBox.name = "Dialog Box"
        dialogBox.size = dialogBoxTextureSize * 2.5
        dialogBox.texture = dialogBoxTexture
        dialogBox.zPosition = GameConfiguration.sceneConfiguration.hudZPosition
        dialogBox.position = position
        
        return dialogBox
    }
    
    /// Add an animated arrow on the current dialog box.
    private func addDialogArrow(node: SKNode) {
        let dialogBoxArrowTexture = SKTexture(imageNamed: "dialogArrow")
        dialogBoxArrowTexture.filteringMode = .nearest
        let dialogBoxTextureArrowSize = dialogBoxArrowTexture.size()
        
        let position = dialogBox.cornerPosition(corner: .bottomRight, padding: EdgeInsets(top: 0, leading: 0, bottom: 35, trailing: 35))
        
        let arrow = SKSpriteNode()
        arrow.size = dialogBoxTextureArrowSize * 1.5
        arrow.texture = dialogBoxArrowTexture
        arrow.zPosition = GameConfiguration.sceneConfiguration.elementHUDZPosition
        arrow.position = position
        node.addChild(arrow)
        
        let animation = SKAction.moveForthAndBack(startPoint: CGPoint(x: arrow.position.x,
                                                                      y: arrow.position.y - 5),
                                                  endPoint: CGPoint(x: arrow.position.x,
                                                                    y: arrow.position.y + 5))
        
        arrow.run(SKAction.repeatForever(animation))
    }
    
    /// Add a character on the current dialog box.
    private func addDialogCharacter(_ characterDialog: GameCharacterDialog,
                                    gameCharacter: GameCharacter,
                                    node: SKNode) {
        let characterTexture = SKTexture(imageNamed: gameCharacter.fullArt)
        characterTexture.filteringMode = .nearest
        let characterTextureSize = characterTexture.size()
        
        let padding = characterDialog.spot == .right ?
        EdgeInsets(top: 50, leading: 0, bottom: 0, trailing:  150) :
        EdgeInsets(top: 50, leading: 150, bottom: 0, trailing:  0)
        
        let corner: SKNode.QuadrilateralCorner = characterDialog.spot == .right ? .topRight : .topLeft
        
        let character = SKSpriteNode()
        character.size = characterTextureSize * 6
        character.texture = characterTexture
        character.zPosition = -1
        character.position = layer.cornerPosition(corner: corner, padding: padding)
        node.addChild(character)
    }
    
    /// Add a text on the current dialog box.
    private func addDialogText(_ text: String, node: SKNode) {
        let parameter = TextManager.Paramater(content: text, fontName: "Outline Pixel7 Solid", fontSize: 20, fontColor: .black, lineSpacing: 10, padding: EdgeInsets(top: 25, leading: 25, bottom: 0, trailing: 25))
        let dialogText = PKTypewriterNode(container: node, parameter: parameter)
        dialogText.name = "Dialog Text"
        node.addChild(dialogText)
        dialogText.start()
        scene.core?.sound.manager.repeatSoundEffect(timeInterval: 0.1, name: GameConfiguration.soundKey.textTyping, volume: 0.1, repeatCount: text.count / 2)
    }
    
    /// Display the total text of the dialog instrantly.
    private func speedUpDialog() {
        guard let dialogBox = layer.childNode(withName: "Dialog Box") else { return }
        guard let dialogText = dialogBox.childNode(withName: "Dialog Text") as? PKTypewriterNode else { return }
        dialogText.displayAllText()
        scene.core?.sound.manager.stopRepeatedSFX()
    }
    
    /// Disable the current dialog.
    private func disableDialog() {
        if let index = scene.game?.level?.dialogs.firstIndex(where: {
            $0.dialog == scene.game?.currentLevelDialog?.dialog
        }) {
            scene.game?.level?.dialogs[index].isDialogAvailable = false
        }
    }
    
    /// Ends the current dialog.
    private func endDialog() {
        disableDialog()
        scene.player?.controllerState = .normal
    }
    
    // MARK: - Updates
    
    /// Update the current gem score.
    public func updateGemScore() {
        let score = layer.childNode(withName: "Score")
        score?.removeFromParent()
        generateGemScore()
    }
    
    /// Remove the action squares from the HUD.
    public func removeActionSquares() {
        actionSquares.forEach { $0.removeFromParent() }
    }
    
    // MARK: - Pause
    
    /// Create the pause button.
    func createPauseButton() {
        
    }
    
    /// Create the pause screen.
    func createPauseScreen() {
        let pauseNode = SKNode()
        pauseNode.name = "Pause Screen"
        scene.addChild(pauseNode)
        generateFilter(on: pauseNode)
        createPauseMenu(on: pauseNode)
    }
    
    /// Remove the pause screen.
    func removePauseScreen() {
        guard let pauseScreen = scene.childNode(withName: "Pause Screen") else { return }
        pauseScreen.removeFromParent()
    }
    
    /// Create the pause menu.
    func createPauseMenu(on node: SKNode) {
        guard let camera = scene.camera else { return }
        let menuNode = SKShapeNode(rectOf: CGSize(width: 250, height: 250))
        menuNode.fillColor = .white
        menuNode.position = camera.position
        node.addChild(menuNode)
    }
    
    /// Pause the HUD.
    func pause() { layer.isPaused = true }
    
    /// Unpause the HUD.
    func unpause() { layer.isPaused = false }
}
