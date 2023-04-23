//
//  GameAnimation.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import SwiftUI
import SpriteKit
import PlayfulKit
import Utility_Toolbox

final class GameAnimation {
    
    init() { }
    
    enum StateID: String, CaseIterable {
        case idle = "idle"
        case effect = "effect"
        case run = "run"
        case runRight = "runRight"
        case runLeft = "runLeft"
        case barrierRight = "barrierRight"
        case barrierLeft = "barrierLeft"
        case hit = "hit"
        case death = "death"
    }
}

// MARK: - Effects

extension GameAnimation {
    
    /// Add a pulsing animation on a node.
    func addShadowPulseEffect(scene: GameScene,
                              node: SKSpriteNode,
                              growth: CGFloat = 1.1,
                              scaling: CGFloat = 1.1,
                              duration: TimeInterval = 0.5) {
        let shadow = SKSpriteNode()
        shadow.name = GameConfiguration.nodeKey.shadowPulseEffect + (node.name ?? "")
        shadow.size = node.size * growth
        shadow.texture = node.texture
        shadow.texture?.filteringMode = .nearest
        shadow.zPosition = node.zPosition - 1
        shadow.position = node.position
        
        scene.addChildSafely(shadow)
        
        let scaleUpAndFadeOut = SKAction.group([
            SKAction.scale(to: scaling, duration: duration),
            SKAction.fadeOut(withDuration: duration),
        ])

        let animation = SKAction.sequence([
            scaleUpAndFadeOut,
            SKAction.scale(to: 1, duration: 0),
            SKAction.fadeIn(withDuration: 0)
        ])

        shadow.run(SKAction.repeatForever(animation))
    }
    
    /// Adds an object effect on a node.
    func addObjectEffect(keyName: String,
                         scene: GameScene,
                         node: PKObjectNode,
                         growth: CGFloat = 1,
                         timeInterval: TimeInterval = 0.05,
                         repeatCount: Int = 1,
                         isRepeatingForever: Bool = false,
                         completion: (() -> Void)? = nil) {
        guard let content = scene.core?.content else { return }
        guard let effectObject = GameObject.getEffect(keyName) else { return }
        
        let effectNode = content.createObject(effectObject, node: node)
        effectNode.size = effectNode.size * growth
        effectNode.zPosition = GameConfiguration.sceneConfiguration.animationZPosition
        effectNode.name = keyName
        
        guard !effectNode.animations.isEmpty else { return }
        
        let animation = animate(node: effectNode,
                                identifier: .effect,
                                filteringMode: .nearest,
                                timeInterval: timeInterval)
        switch true {
        case isRepeatingForever:
            effectNode.run(SKAction.repeatForever(animation))
        default:
            SKAction.animate(action: SKAction.repeat(animation, count: repeatCount),
                             node: effectNode) {
                effectNode.removeFromParent()
                completion?()
            }
        }
    }
    
    /// Scene transition effect.
    func sceneTransitionEffect(scene: GameScene,
                               effectAction: SKAction,
                               isFadeIn: Bool = true,
                               isShowingTitle: Bool = true,
                               completion: (() -> Void)?) {
        let effectNode = SKShapeNode(rectOf: scene.size * 3)
        effectNode.alpha = isFadeIn ? 1 : 0
        effectNode.fillColor = .black
        effectNode.strokeColor = .black
        effectNode.zPosition = GameConfiguration.sceneConfiguration.screenFilterZPosition
        effectNode.position = scene.player?.node.position ?? .zero
        scene.addChild(effectNode)
        let showTitleAction = SKAction.sequence([
            SKAction.run {
                self.titleTransitionEffect(scene: scene) {
                    scene.game?.controller?.enable()
                    scene.core?.hud?.addContent()
                }
            },
            SKAction.wait(forDuration: 4)
        ])
        let completionAction = SKAction.run {
            scene.isUserInteractionEnabled = true
            completion?()
        }
        let sequence = SKAction.sequence([
            SKAction.run { scene.game?.controller?.disable() },
            effectAction,
            isShowingTitle ? showTitleAction : SKAction.empty(),
            completionAction
        ])
        effectNode.run(sequence)
    }
    
    /// Title transition effect on the scene.
    func titleTransitionEffect(scene: GameScene, completion: (() -> Void)?) {
        guard let level = scene.game?.level else { return }
        guard let game = scene.game else { return }
        guard !game.hasTitleBeenDisplayed else { return }
        
        let textManager = TextManager()
        let paramater = TextManager.Paramater(content: level.name,
                                              fontName: GameConfiguration.sceneConfiguration.titleFont,
                                              fontSize: 40,
                                              fontColor: .white,
                                              strokeWidth: -10,
                                              strokeColor: .black)
        let attributedText = textManager.attributedText(parameter: paramater)
        
        let titleNode = SKLabelNode(attributedText: attributedText)
        titleNode.alpha = 0
        titleNode.zPosition = GameConfiguration.sceneConfiguration.animationZPosition
        titleNode.position = scene.camera?.position ?? .zero
        scene.addChildSafely(titleNode)
        
        let sequence = SKAction.sequence([
            SKAction.fadeIn(withDuration: 2),
            SKAction.fadeOut(withDuration: 2),
            SKAction.removeFromParent()
        ])
        
        scene.game?.controller?.disable()
        
        SKAction.animate(action: sequence, node: titleNode) {
            scene.game?.hasTitleBeenDisplayed = true
            completion?()
        }
    }
    
    /// Add a circular smoke effect on a node.
    func addCircularSmokeEffect(scene: GameScene, node: PKObjectNode) {
        
        let name = "Circular Smoke Effect"
        let tileSize = GameConfiguration.sceneConfiguration.tileSize
        
        guard let content = scene.core?.content else { return }
        guard let effectObject = GameObject.getEffect(name) else { return }
        
        let effectNode = content.createObject(effectObject, at: node.coordinate)
        effectNode.zPosition = GameConfiguration.sceneConfiguration.animationZPosition
        effectNode.size = CGSize(width: tileSize.width * 2, height: tileSize.height)
        
        guard !effectNode.animations.isEmpty else { return }
        
        let animation = animate(node: effectNode,
                                identifier: .effect,
                                filteringMode: .nearest,
                                timeInterval: 0.05)
        
        let sequence = SKAction.sequence([
            animation,
            SKAction.removeFromParent()
        ])
        
        effectNode.run(sequence)
    }
    
    /// Add a screen shake effect on the scene camera.
    func addScreenShakeEffect(on scene: GameScene) {
        guard let camera = scene.camera else { return }
        let shake = SKAction.shake(duration: 0.1, amplitudeX: 25, amplitudeY: 25)
        SKAction.animate(startCompletion: {
            scene.core?.gameCamera?.isUpdatingMovement = false
        }, action: shake, node: camera) {
            scene.core?.gameCamera?.isUpdatingMovement = true
        }
    }
}

// MARK: - State ID animations

extension GameAnimation {
    
    /// Animate a node with a state identifier.
    func animate(node: PKObjectNode,
                 identifier: StateID,
                 filteringMode: SKTextureFilteringMode = .linear,
                 timeInterval: TimeInterval = 0.05) -> SKAction {
        guard node.animation(from: identifier.rawValue) != nil else { return SKAction.empty() }
        let animation = node.animatedAction(with: identifier.rawValue,
                                            filteringMode: filteringMode,
                                            timeInterval: timeInterval)
        return animation
    }
    
    /// Animate a node with an idle state identifier.
    func idle(node: PKObjectNode,
              filteringMode: SKTextureFilteringMode = .linear,
              timeInterval: TimeInterval = 0.05) {
        let action = animate(node: node,
                             identifier: .idle,
                             filteringMode: filteringMode,
                             timeInterval: timeInterval)
        
        node.run(SKAction.repeatForever(action))
    }
    
    /// Animate a node with a hit state identifier.
    func hit(node: PKObjectNode,
             filteringMode: SKTextureFilteringMode = .linear,
             timeInterval: TimeInterval = 0.05) {
        node.run(animate(node: node,
                         identifier: .hit,
                         filteringMode: filteringMode,
                         timeInterval: timeInterval))
    }
    
    /// Animate a node with an death state identifier.
    func destroy(node: PKObjectNode,
                 filteringMode: SKTextureFilteringMode = .linear,
                 timeInterval: TimeInterval = 0.05,
                 actionAfter: (() -> Void)? = nil) {
        guard node.animation(from: StateID.death.rawValue) != nil else { return }
        
        let sequence = SKAction.sequence([
            animate(node: node,
                    identifier: .death,
                    filteringMode: filteringMode,
                    timeInterval: timeInterval),
            SKAction.removeFromParent(),
        ])
        
        SKAction.animate(action: sequence, node: node, endCompletion: actionAfter)
    }
    
    /// Remove a node then animate with its death state.
    func delayedDestroy(scene: GameScene,
                        node: PKObjectNode,
                        timeInterval: TimeInterval = 0.05,
                        actionAfter: (() -> Void)? = nil) {
        let animatedNode = PKObjectNode()
        animatedNode.size = node.size
        animatedNode.zPosition = GameConfiguration.sceneConfiguration.objectZPosition
        animatedNode.position = node.position
        animatedNode.animations = node.animations
        
        scene.addChildSafely(animatedNode)
        
        let sequence = SKAction.sequence([
            animate(node: animatedNode,
                    identifier: .death,
                    filteringMode: .nearest,
                    timeInterval: timeInterval),
            SKAction.removeFromParent(),
        ])
        
        SKAction.animate(action: sequence, node: animatedNode, endCompletion: actionAfter)
        
        node.removeFromParent()
    }
}
