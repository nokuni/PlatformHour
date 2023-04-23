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

final class GameHUD {
    init(scene: GameScene) {
        self.scene = scene
        create()
    }
    
    var scene: GameScene
    
    private let layer = SKShapeNode(rectOf: .screen)
    private let contentContainer = SKNode()
    let conversationBox = SKSpriteNode()
    let energyCharger = SKSpriteNode()
    let gemScore = SKNode()
    
    var actionSquares: [SKSpriteNode] {
        let actionNodes = layer.childNodes(named: "Action Square")
        let actions = actionNodes.compactMap { $0 as? SKSpriteNode }
        return actions
    }
    
    private var actionSequenceHUDConstraints: EdgeInsets {
        let leading = GameConfiguration.sceneConfiguration.tileSize.width * 4
        let constraints = EdgeInsets(top: 40, leading: leading, bottom: 0, trailing: 0)
        return constraints
    }
    
    // MARK: - Creation/Removal
    
    func create() {
        createLayer()
        addContentContainer()
        addContent()
    }
    
    /// Generate a filter over the HUD.
    private func generateFilter(color: UIColor = .black, alpha: CGFloat = 0.7, on node: SKNode) {
        guard let camera = scene.camera else { return }
        let filterNode = SKShapeNode(rectOf: CGSize.screen * 2)
        filterNode.strokeColor = color
        filterNode.fillColor = color
        filterNode.alpha = alpha
        filterNode.zPosition = GameConfiguration.sceneConfiguration.screenFilterZPosition
        filterNode.position = camera.position
        node.addChildSafely(filterNode)
    }
}

// MARK: - Pause

extension GameHUD {
    
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

// MARK: - Create

// MARK: - Updates

extension GameHUD {
    
    /// Updates the current gem score.
    func updateGemScore() {
        removeGemScore()
        addGemScore()
    }
    
    /// Updates the current energy amount.
    func updateEnergy() {
        removeEnergyCharger()
        addEnergyCharger()
    }
}

// MARK: - Create/Adds

extension GameHUD {
    
    /// Create the layer on the scene.
    private func createLayer() {
        layer.fillColor = .clear
        layer.strokeColor = .clear
        layer.zPosition = GameConfiguration.sceneConfiguration.hudLayerZPosition
        scene.camera?.addChildSafely(layer)
    }
    
    /// Adds the content container on the layer.
    private func addContentContainer() {
        layer.addChildSafely(contentContainer)
    }
    
    /// Adds the content on the content container.
    func addContent() {
        removeContent()
        addEnergyCharger()
        //addGemScore()
    }
    
    /// Adds the gem score on the layer.
    private func addGemScore() {
        
        guard let player = scene.player else { return }
        
        gemScore.setScale(0.8)
        gemScore.position = layer.cornerPosition(corner: .topLeft, padding: EdgeInsets(top: 40, leading: 40, bottom: 0, trailing: 0))
        contentContainer.addChildSafely(gemScore)
        
        let xMarkNode = SKSpriteNode(imageNamed: GameConfiguration.imageKey.xMark)
        xMarkNode.texture?.filteringMode = .nearest
        xMarkNode.size = GameConfiguration.sceneConfiguration.tileSize
        xMarkNode.position = CGPoint(x: GameConfiguration.sceneConfiguration.tileSize.width / 2, y: 0)
        gemScore.addChildSafely(xMarkNode)
        
        player.bag.count.intoSprites(with: GameConfiguration.imageKey.indicator,
                                     filteringMode: .nearest,
                                     spacing: 0.5,
                                     of: GameConfiguration.sceneConfiguration.tileSize,
                                     at: CGPoint(x: GameConfiguration.sceneConfiguration.tileSize.width * 1.5,
                                                 y: 0),
                                     on: gemScore)
        
        let item = SKSpriteNode(imageNamed: GameConfiguration.imageKey.hudBlueGem)
        item.texture?.filteringMode = .nearest
        item.size = GameConfiguration.sceneConfiguration.tileSize
        item.position = .zero
        gemScore.addChildSafely(item)
    }
    
    /// Adds the energy charger.
    private func addEnergyCharger() {
        guard let player = scene.player else { return }
        guard let game = scene.game else { return }
        
        energyCharger.size = GameConfiguration.sceneConfiguration.tileSize
        energyCharger.zPosition = GameConfiguration.sceneConfiguration.elementHUDZPosition
        energyCharger.position = layer.cornerPosition(corner: .topLeft,
                                                      padding: EdgeInsets(top: 40, leading: 60, bottom: 0, trailing: 0))
        
        let animation = SKAction.animate(with: player.energyFrames(game: game),
                                         filteringMode: .nearest,
                                         timePerFrame: 0.2)
        
        energyCharger.run(SKAction.repeatForever(animation))
        
        contentContainer.addChildSafely(energyCharger)
        
        addEnergyCounter()
    }
    
    private func addEnergyCounter() {
        guard let player = scene.player else { return }
        let textManager = TextManager()
        let paramater = TextManager.Paramater(content: "\(player.energy)",
                                              fontName: GameConfiguration.sceneConfiguration.titleFont,
                                              fontSize: 20,
                                              fontColor: .white,
                                              strokeWidth: -10,
                                              strokeColor: .black)
        let attributedText = textManager.attributedText(parameter: paramater)
        
        let energyCounterNode = SKLabelNode(attributedText: attributedText)
        energyCounterNode.zPosition = GameConfiguration.sceneConfiguration.hudZPosition
        energyCounterNode.position = CGPoint(x: GameConfiguration.sceneConfiguration.tileSize.width,
                                             y: 0)
        energyCharger.addChildSafely(energyCounterNode)
    }
    
    /// Adds an action square on the action sequence bar.
    func addActionSquares() {
        guard let player = scene.player else { return }
        
        var actionSquares: [SKSpriteNode] = []
        
        for index in 0..<player.currentRoll.rawValue {
            let actionSquare = actionSquare(index: index)
            let animation = SKAction.sequence([
                SKAction.scale(by: 1.1, duration: 0.1),
                SKAction.scale(by: 0.9, duration: 0.1),
                SKAction.scale(by: 1, duration: 0.1)
            ])
            actionSquare.run(animation)
            
            actionSquares.append(actionSquare)
        }
        
        let position = layer.cornerPosition(corner: .topLeft, padding: actionSequenceHUDConstraints)
        
        let parameter = AssemblyManager.Parameter(axes: .horizontal, adjustement: .leading, horizontalSpacing: 1, verticalSpacing: 1, columns: 6)
        
        GameConfiguration.assemblyManager.createNodeCollectionWithDelay(of: actionSquares, at: position, in: layer, parameter: parameter, delay: 0.1, actionOnGoing: nil, actionOnEnd: {
            self.endOfActionSquaresAnimation()
        })
    }
    
    /// Action squares animation completion logic.
    private func endOfActionSquaresAnimation() {
        scene.core?.state.switchOn(newStatus: .inAction)
        scene.game?.controller?.action.enable()
    }
    
    /// Returns an action square.
    private func actionSquare(index: Int) -> SKSpriteNode {
        let actionSquare = SKSpriteNode(imageNamed: GameConfiguration.imageKey.actionSquare)
        actionSquare.name = "\(GameConfiguration.nodeKey.actionSquare) \(index)"
        actionSquare.texture?.filteringMode = .nearest
        actionSquare.zPosition = GameConfiguration.sceneConfiguration.elementHUDZPosition
        actionSquare.size = GameConfiguration.sceneConfiguration.tileSize
        return actionSquare
    }
}

// MARK: - Removals

extension GameHUD {
    
    /// Removes the current content.
    func removeContent() {
        contentContainer.removeAllChildren()
    }
    
    /// Removes the action squares from the action bar.
    func removeActionSquares() {
        actionSquares.forEach { $0.removeFromParent() }
    }
    
    private func removeConversationBox() {
        conversationBox.removeAllChildren()
        conversationBox.removeFromParent()
    }
    
    /// Removes the gem score from the layer.
    private func removeGemScore() {
        gemScore.removeAllChildren()
        gemScore.removeFromParent()
    }
    
    /// Removes the energy charger from the layer.
    private func removeEnergyCharger() {
        energyCharger.removeAllChildren()
        energyCharger.removeFromParent()
    }
}

// MARK: - Conversation Box

extension GameHUD {
    
    /// Adds the conversation box.
    func addConversationBox() {
        
        guard let levelConversation = scene.game?.currentLevelConversation else { return }
        guard let conversationData = GameConversation.get(levelConversation.name) else { return }
        
        if scene.game?.currentConversation == nil { scene.game?.currentConversation = conversationData }
        
        guard let conversation = scene.game?.currentConversation else { return }
        
        let dialog = conversation.dialogs[conversation.currentDialogIndex]
        
        configureConversationBox(dialog: dialog)
        
        layer.addChildSafely(conversationBox)
        
        addConversationArrow(node: conversationBox)
        
        if let conversationCharacter = dialog.character,
           let character = GameCharacter.get(conversationCharacter) {
            addConversationCharacter(dialog, gameCharacter: character, node: conversationBox)
        }
        
        let lineIndex = conversation.dialogs[conversation.currentDialogIndex].currentLineIndex
        let text = conversation.dialogs[conversation.currentDialogIndex].lines[lineIndex]
        
        addConversationText(text, node: conversationBox)
        
        if let speakerName = dialog.character {
            addSpeakerName(dialog, name: speakerName, node: conversationBox)
        }
    }
    
    /// Configures the conversation box.
    private func configureConversationBox(dialog: GameDialog) {
        
        let dialogBoxTexture = SKTexture(imageNamed: GameConfiguration.imageKey.conversationBox)
        dialogBoxTexture.filteringMode = .nearest
        
        let dialogBoxTextureSize = dialogBoxTexture.size()
        
        let position = layer.cornerPosition(corner: .bottomLeft, padding: EdgeInsets(top: 0, leading: CGSize.screen.width * 0.5, bottom: 100, trailing: 0))
        
        conversationBox.name = GameConfiguration.nodeKey.conversationBox
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
    private func addConversationCharacter(_ dialog: GameDialog,
                                          gameCharacter: GameCharacter,
                                          node: SKNode) {
        let characterTexture = SKTexture(imageNamed: gameCharacter.fullArt)
        characterTexture.filteringMode = .nearest
        let characterTextureSize = characterTexture.size()
        
        let padding = EdgeInsets(top: 80, leading: 60, bottom: 0, trailing:  0)
        
        let character = SKSpriteNode()
        character.size = characterTextureSize * 2.5
        character.texture = characterTexture
        character.zPosition = conversationBox.zPosition + 1
        character.position = conversationBox.cornerPosition(corner: .topLeft, padding: padding)
        node.addChildSafely(character)
    }
    
    /// Add a text on the conversation box.
    private func addConversationText(_ text: String, node: SKNode) {
        let padding = EdgeInsets(top: 45, leading: 130, bottom: 0, trailing: 30)
        let localizedText = text.localized(Game.shared.language)
        let parameter = TextManager.Paramater(content: localizedText,
                                              fontName: GameConfiguration.sceneConfiguration.textFont,
                                              fontSize: 18,
                                              fontColor: .black,
                                              lineSpacing: 5,
                                              padding: padding)
        let dialogText = PKTypewriterNode(container: node, parameter: parameter)
        dialogText.whileCompletion = { self.scene.core?.sound.textTyping() }
        dialogText.name = GameConfiguration.nodeKey.conversationText
        node.addChildSafely(dialogText)
        dialogText.start()
        //scene.core?.sound.manager.repeatSoundEffect(timeInterval: 0.1, name: GameConfiguration.soundKey.textTyping, volume: 0.1, repeatCount: text.count / 2)
    }
    
    /// Add the speaker name to the conversation box.
    private func addSpeakerName(_ dialog: GameDialog, name: String, node: SKNode) {
        guard let game = scene.game else { return }
        let textManager = TextManager()
        guard let characterInformation = game.currentSave?.characterInformations?.first(where: {
            $0.keys.first == name
        }) else { return }
        let parameter = TextManager.Paramater(content: characterInformation.values.first ?? "???",
                                              fontName: GameConfiguration.sceneConfiguration.titleFont,
                                              fontSize: 10,
                                              fontColor: .white,
                                              horizontalAlignmentMode: .center)
        
        let padding =  EdgeInsets(top: 16, leading: 70, bottom: 0, trailing:  0)
        
        let attributedText = textManager.attributedText(parameter: parameter)
        let dialogText = SKLabelNode(attributedText: attributedText)
        dialogText.name = GameConfiguration.nodeKey.conversationText
        dialogText.zPosition = conversationBox.zPosition + 1
        dialogText.position = conversationBox.cornerPosition(corner: .topLeft, padding: padding)
        node.addChildSafely(dialogText)
    }
}

// MARK: - Conversation Logic

extension GameHUD {
    
    /// Pass the current line of text.
    func passLine() {
        if let conversationText = conversationBox.childNode(withName: GameConfiguration.nodeKey.conversationText) as? PKTypewriterNode {
            conversationText.hasFinished() ? nextLine() : speedUpLine()
        }
    }
    
    private func conversationPressEffect(completion: (() -> Void)?) {
        let animation = SKAction.scaleUpAndDown(from: 0.99, with: 0.05, to: 1, with: 0.05)
        SKAction.animate(action: animation, node: conversationBox) { completion?() }
    }
    
    /// Display the next line of a dialog.
    func nextLine() {
        conversationPressEffect {
            self.removeConversationBox()
            guard let index = self.scene.game?.currentConversation?.currentDialogIndex else { return }
            self.scene.game?.currentConversation?.dialogs[index].revealFinalName(game: self.scene.game)
            self.scene.game?.currentConversation?.dialogs[index].moveOnNextLine()
            guard let isEndOfLine = self.scene.game?.currentConversation?.dialogs[index].isEndOfLine else { return }
            !isEndOfLine ? self.addConversationBox() : self.nextDialog()
        }
    }
    
    /// Display the next dialog.
    private func nextDialog() {
        scene.game?.currentConversation?.moveOnNextDialog()
        guard let isEndOfConversation = scene.game?.currentConversation?.isEndOfConversation else { return }
        !isEndOfConversation ? addConversationBox() : endConversation()
    }
    
    /// Display the total text of the dialog instrantly.
    private func speedUpLine() {
        let conversationText = conversationBox.childNode(withName: GameConfiguration.nodeKey.conversationText) as? PKTypewriterNode
        conversationText?.displayAllText()
        scene.core?.sound.manager.stopRepeatedSFX()
    }
    
    /// Disable the current dialog.
    private func disableConversation() {
        guard let currentLevelConversation = scene.game?.currentLevelConversation else { return }
        scene.game?.saves[0].passedConversations?.append(currentLevelConversation.name)
        scene.game?.updateSaves()
    }
    
    /// Reset the current conversation.
    private func resetConversation() {
        scene.game?.currentLevelConversation = nil
        scene.game?.currentConversation = nil
    }
    
    /// Returns the cinematic after the conversation.
    private var cinematicAfterConversation: LevelCinematic? {
        guard let level = scene.game?.level else { return nil }
        if let cinematicCompletion = scene.game?.currentConversation?.cinematicCompletion {
            return level.cinematics.first(where: { $0.name == cinematicCompletion })
        }
        return nil
    }
    
    /// Ends the current dialog.
    private func endConversation() {
        guard let game = scene.game else { return }
        if let cinematicAfterConversation = cinematicAfterConversation {
            scene.core?.event?.startCinematic(levelCinematic: cinematicAfterConversation)
        } else {
            scene.core?.state.switchOn(newStatus: .inDefault)
            if game.hasTitleBeenDisplayed { endConversationCompletion() }
            scene.core?.animation?.titleTransitionEffect(scene: scene) {
                self.endConversationCompletion()
            }
        }
        disableConversation()
        resetConversation()
    }
    
    /// Completion on the end of the conversation
    private func endConversationCompletion() {
        guard let player = scene.player else { return }
        scene.game?.controller?.enable()
        scene.core?.hud?.addContent()
        scene.core?.gameCamera?.followedObject = player.node
    }
}
