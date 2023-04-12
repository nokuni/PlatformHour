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
        create()
    }
    
    public var scene: GameScene
    
    private let layer = SKShapeNode(rectOf: .screen)
    private let contentContainer = SKNode()
    private let actionSequence = SKNode()
    public let conversationBox = SKSpriteNode()
    
    public var actionSquares: [SKSpriteNode] {
        let actionNodes = actionSequence.childNodes(named: "Action Square")
        let actions = actionNodes.compactMap { $0 as? SKSpriteNode }
        return actions
    }
    
    private var actionSequenceHUDConstraints: EdgeInsets {
        let leading = (layer.frame.width / 2) - (GameConfiguration.sceneConfiguration.tileSize.width * 3) + (GameConfiguration.sceneConfiguration.tileSize.width / 2)
        let constraints = EdgeInsets(top: 40, leading: leading, bottom: 0, trailing: 0)
        return constraints
    }
    
    // MARK: - Creation/Removal
    
    public func create() {
        createLayer()
        addContentContainer()
        addContent()
    }
    
    /// Create the layer on the scene.
    private func createLayer() {
        layer.name = "HUD Layer"
        layer.fillColor = .clear
        layer.strokeColor = .clear
        layer.zPosition = GameConfiguration.sceneConfiguration.hudZPosition
        scene.camera?.addChildSafely(layer)
    }
    
    /// Generate a filter over the HUD.
    private func generateFilter(color: UIColor = .black, alpha: CGFloat = 0.7, on node: SKNode) {
        guard let camera = scene.camera else { return }
        let filterNode = SKShapeNode(rectOf: CGSize.screen * 2)
        filterNode.strokeColor = color
        filterNode.fillColor = color
        filterNode.alpha = alpha
        filterNode.zPosition = GameConfiguration.sceneConfiguration.overOverlayZPosition
        filterNode.position = camera.position
        node.addChildSafely(filterNode)
    }
    
    // MARK: - Dialog Box
    
    /// Pass the current line of text.
    public func passLine() {
        if let dialogText = conversationBox.childNode(withName: "Dialog Text") as? PKTypewriterNode {
            dialogText.hasFinished() ? nextLine() : speedUpLine()
        }
    }
    
    /// Display the next line of a dialog.
    public func nextLine() {
        conversationBox.removeAllChildren()
        conversationBox.removeFromParent()
        
        guard let index = scene.game?.currentConversation?.currentDialogIndex else { return }
        
        scene.game?.currentConversation?.dialogs[index].moveOnNextLine()
        
        guard let isEndOfLine = scene.game?.currentConversation?.dialogs[index].isEndOfLine else { return }
        
        !isEndOfLine ? addConversationBox() : nextDialog()
    }
    
    /// Display the next dialog.
    private func nextDialog() {
        scene.game?.currentConversation?.moveOnNextDialog()
        guard let isEndOfConversation = scene.game?.currentConversation?.isEndOfConversation else { return }
        !isEndOfConversation ? addConversationBox() : endConversation()
    }
    
    /// Display the total text of the dialog instrantly.
    private func speedUpLine() {
        let dialogText = conversationBox.childNode(withName: "Dialog Text") as? PKTypewriterNode
        dialogText?.displayAllText()
        scene.core?.sound.manager.stopRepeatedSFX()
    }
    
    /// Disable the current dialog.
    private func disableConversation() {
        if let index = scene.game?.level?.conversations.firstIndex(where: {
            $0.conversation == scene.game?.currentLevelConversation?.conversation
        }) {
            scene.game?.level?.conversations[index].isAvailable = false
        }
    }
    
    public func resetConversation() {
        scene.game?.currentLevelConversation = nil
        scene.game?.currentConversation = nil
    }
    
    private var cinematicAfterConversation: LevelCinematic? {
        guard let level = scene.game?.level else { return nil }
        if let cinematicCompletion = scene.game?.currentConversation?.cinematicCompletion {
            return level.cinematics.first(where: { $0.name == cinematicCompletion })
        }
        return nil
    }
    
    /// Ends the current dialog.
    private func endConversation() {
        if let cinematicAfterConversation = cinematicAfterConversation {
            scene.core?.event?.playCinematic(cinematic: cinematicAfterConversation)
        } else {
            scene.core?.state.switchOn(newStatus: .inDefault)
        }
        disableConversation()
        resetConversation()
    }
}

// MARK: - Pause

public extension GameHUD {
    
    /// Create the pause button.
    private func createPauseButton() {
        // Create the pause button
    }
    
    /// Create the pause screen.
    func createPauseScreen() {
        let pauseNode = SKNode()
        pauseNode.name = "Pause Screen"
        scene.addChildSafely(pauseNode)
        generateFilter(on: pauseNode)
        createPauseMenu(on: pauseNode)
    }
    
    /// Remove the pause screen.
    func removePauseScreen() {
        guard let pauseScreen = scene.childNode(withName: "Pause Screen") else { return }
        pauseScreen.removeFromParent()
    }
    
    /// Create the pause menu.
    private func createPauseMenu(on node: SKNode) {
        guard let camera = scene.camera else { return }
        let menuNode = SKShapeNode(rectOf: CGSize(width: 250, height: 250))
        menuNode.fillColor = .white
        menuNode.position = camera.position
        node.addChildSafely(menuNode)
    }
    
    /// Pause the HUD.
    func pause() { layer.isPaused = true }
    
    /// Unpause the HUD.
    func unpause() { layer.isPaused = false }
}

// MARK: - Updates

public extension GameHUD {
    
    /// Update the current gem score.
    func updateGemScore() {
        removeGemScore()
        addGemScore()
    }
}

// MARK: - Adds

public extension GameHUD {
    
    /// Adds the content container on the layer.
    private func addContentContainer() {
        layer.addChildSafely(contentContainer)
    }
    
    /// Adds the content on the content container.
    func addContent() {
        addGemScore()
        addActionSequenceBar()
    }
    
    /// Adds the action sequence bar on the layer.
    private func addActionSequenceBar() {
        
        actionSequence.name = "Action Sequence"
        contentContainer.addChildSafely(actionSequence)
        
        let sequenceImages = ["sequenceSpace0", "sequenceSpace1", "sequenceSpace1", "sequenceSpace1", "sequenceSpace1", "sequenceSpace2"]
        var sequenceHUD: [SKSpriteNode] = []
        
        for image in sequenceImages {
            let hud = SKSpriteNode(imageNamed: image)
            hud.texture?.filteringMode = .nearest
            hud.size = GameConfiguration.sceneConfiguration.tileSize
            sequenceHUD.append(hud)
        }
        
        let sequencePosition = layer.cornerPosition(corner: .topLeft, padding: actionSequenceHUDConstraints)
        
        GameConfiguration.assemblyManager.createNodeList(of: sequenceHUD, at: sequencePosition, in: contentContainer, axes: .horizontal, adjustement: .leading, spacing: 1)
    }
    
    /// Adds the gem score on the layer.
    private func addGemScore() {
        
        guard let player = scene.player else { return }
        
        let score = SKNode()
        score.name = "Score"
        score.setScale(0.8)
        score.position = layer.cornerPosition(corner: .topLeft, padding: EdgeInsets(top: 40, leading: 40, bottom: 0, trailing: 0))
        contentContainer.addChildSafely(score)
        
        let xLetter = SKSpriteNode(imageNamed: "xLetter")
        xLetter.texture?.filteringMode = .nearest
        xLetter.size = GameConfiguration.sceneConfiguration.tileSize
        xLetter.position = CGPoint(x: GameConfiguration.sceneConfiguration.tileSize.width / 2, y: 0)
        score.addChildSafely(xLetter)
        
        player.bag.count.intoSprites(with: "indicator",
                                     filteringMode: .nearest,
                                     spacing: 0.5,
                                     of: GameConfiguration.sceneConfiguration.tileSize,
                                     at: CGPoint(x: GameConfiguration.sceneConfiguration.tileSize.width * 1.5,
                                                 y: 0),
                                     on: score)
        
        let item = SKSpriteNode(imageNamed: "hudGem")
        item.name = "Orb"
        item.texture?.filteringMode = .nearest
        item.size = GameConfiguration.sceneConfiguration.tileSize
        item.position = .zero
        score.addChildSafely(item)
    }
    
    /// Adds an action square on the action sequence bar.
    func addActionSquares() {
        guard let player = scene.player else { return }
        
        var actions: [SKSpriteNode] = []
        
        for index in 0..<player.currentRoll.rawValue {
            let action = SKSpriteNode(imageNamed: GameConfiguration.imageKey.actionSquare)
            action.name = "Action Square \(index)"
            action.texture?.filteringMode = .nearest
            action.zPosition = GameConfiguration.sceneConfiguration.elementHUDZPosition
            action.size = GameConfiguration.sceneConfiguration.tileSize
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
}

// MARK: - Removals

public extension GameHUD {
    
    /// Removes the current content.
    func removeContent() {
        contentContainer.removeAllChildren()
    }
    
    /// Removes the action squares from the action bar.
    func removeActionSquares() {
        actionSquares.forEach { $0.removeFromParent() }
    }
    
    /// Removes the gem score from the layer.
    private func removeGemScore() {
        let score = layer.childNode(withName: "Score")
        score?.removeFromParent()
    }
}

// MARK: - Dialog

public extension GameHUD {
    
    /// Adds the conversation box.
    func addConversationBox() {
        
        configureConversationBox()
        
        layer.addChildSafely(conversationBox)
        
        addConversationArrow(node: conversationBox)
        
        guard let levelConversation = scene.game?.currentLevelConversation else { return }
        guard let conversationData = GameConversation.get(levelConversation.conversation) else { return }
        
        if scene.game?.currentConversation == nil { scene.game?.currentConversation = conversationData }
        
        guard let currentConversation = scene.game?.currentConversation else { return }
        
        guard let dialog = scene.game?.currentConversation else { return }
        
        let dialogs = currentConversation.dialogs[dialog.currentDialogIndex]
        
        if let conversationCharacter = dialogs.character,
           let character = GameCharacter.get(conversationCharacter) {
            addConversationCharacter(dialogs, gameCharacter: character, node: conversationBox)
        }
        
        let lineIndex = currentConversation.dialogs[dialog.currentDialogIndex].currentLineIndex
        let text = currentConversation.dialogs[dialog.currentDialogIndex].lines[lineIndex]
        
        addConversationText(text, node: conversationBox)
    }
    
    /// Configures the conversation box.
    private func configureConversationBox() {
        
        let dialogBoxTexture = SKTexture(imageNamed: "dialogBox")
        dialogBoxTexture.filteringMode = .nearest
        
        let dialogBoxTextureSize = dialogBoxTexture.size()
        
        let position = layer.cornerPosition(corner: .bottomLeft, padding: EdgeInsets(top: 0, leading: CGSize.screen.width * 0.5, bottom: 100, trailing: 0))
        
        conversationBox.name = "Conversation Box"
        conversationBox.size = dialogBoxTextureSize * 2.5
        conversationBox.texture = dialogBoxTexture
        conversationBox.zPosition = GameConfiguration.sceneConfiguration.hudZPosition
        conversationBox.position = position
        
    }
    
    /// Adds an animated arrow on the current conversation box.
    private func addConversationArrow(node: SKNode) {
        let dialogBoxArrowTexture = SKTexture(imageNamed: "dialogArrow")
        dialogBoxArrowTexture.filteringMode = .nearest
        let dialogBoxTextureArrowSize = dialogBoxArrowTexture.size()
        
        let position = conversationBox.cornerPosition(corner: .bottomRight, padding: EdgeInsets(top: 0, leading: 0, bottom: 35, trailing: 35))
        
        let arrow = SKSpriteNode()
        arrow.size = dialogBoxTextureArrowSize * 1.5
        arrow.texture = dialogBoxArrowTexture
        arrow.zPosition = GameConfiguration.sceneConfiguration.elementHUDZPosition
        arrow.position = position
        node.addChildSafely(arrow)
        
        let animation = SKAction.moveForthAndBack(startPoint: CGPoint(x: arrow.position.x,
                                                                      y: arrow.position.y - 5),
                                                  endPoint: CGPoint(x: arrow.position.x,
                                                                    y: arrow.position.y + 5))
        
        arrow.run(SKAction.repeatForever(animation))
    }
    
    /// Add a character on the current conversation box.
    private func addConversationCharacter(_ characterDialog: GameCharacterDialog,
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
        node.addChildSafely(character)
    }
    
    /// Add a text on the conversation box.
    private func addConversationText(_ text: String, node: SKNode) {
        let parameter = TextManager.Paramater(content: text, fontName: "Outline Pixel7 Solid", fontSize: 20, fontColor: .black, lineSpacing: 10, padding: EdgeInsets(top: 25, leading: 25, bottom: 0, trailing: 25))
        let dialogText = PKTypewriterNode(container: node, parameter: parameter)
        dialogText.name = "Dialog Text"
        node.addChildSafely(dialogText)
        dialogText.start()
        scene.core?.sound.manager.repeatSoundEffect(timeInterval: 0.1, name: GameConfiguration.soundKey.textTyping, volume: 0.1, repeatCount: text.count / 2)
    }
}
