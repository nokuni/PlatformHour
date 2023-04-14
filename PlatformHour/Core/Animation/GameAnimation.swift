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

final public class GameAnimation {
    
    public init() { }
    
    public enum StateID: String, CaseIterable {
        case idle = "idle"
        case effect = "effect"
        case run = "run"
        case runRight = "runRight"
        case runLeft = "runLeft"
        case hit = "hit"
        case death = "death"
    }
}

// MARK: - Effects

public extension GameAnimation {
    
    /// Add a pulsing animation on a node.
    func addShadowPulseEffect(scene: GameScene,
                              node: SKSpriteNode,
                              growth: CGFloat = 1.1,
                              scaling: CGFloat = 1.1,
                              duration: TimeInterval = 0.5) {
        let shadow = SKSpriteNode()
        shadow.size = node.size * growth
        shadow.texture = node.texture
        shadow.texture?.filteringMode = .nearest
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
                         timeInterval: TimeInterval = 0.05,
                         repeatCount: Int = 1,
                         isRepeatingForever: Bool = false) {
        guard let content = scene.core?.content else { return }
        guard let effectObject = GameObject.getEffect(keyName) else { return }
        
        let effectNode = content.createObject(effectObject, node: node)
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
            effectNode.run(SKAction.repeat(animation, count: repeatCount))
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
        effectNode.zPosition = GameConfiguration.sceneConfiguration.overlayZPosition
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
            effectAction,
            isShowingTitle ? showTitleAction : SKAction.empty(),
            completionAction
        ])
        effectNode.run(sequence)
    }
    
    /// Title transition effect on the scene.
    func titleTransitionEffect(scene: GameScene, completion: (() -> Void)?) {
        guard let level = scene.game?.level else { return }
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
        titleNode.zPosition = GameConfiguration.sceneConfiguration.elementHUDZPosition
        titleNode.position = scene.camera?.position ?? .zero
        scene.addChildSafely(titleNode)
        
        let sequence = SKAction.sequence([
            SKAction.fadeIn(withDuration: 2),
            SKAction.fadeOut(withDuration: 2),
            SKAction.removeFromParent()
        ])
        
        SKAction.animate(startCompletion: scene.game?.controller?.disable,
                         action: sequence,
                         node: titleNode) {
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
    
#warning("Effect not used")
    /// Add an orb split effect at a position on the scene.
    func orbSplitEffect(scene: GameScene, on position: CGPoint) {
        let tileSize = GameConfiguration.sceneConfiguration.tileSize
        let positions = [
            CGPoint(x: position.x, y: position.y + tileSize.height),
            CGPoint(x: position.x + tileSize.width, y: position.y + tileSize.height),
            CGPoint(x: position.x + tileSize.width, y: position.y),
            CGPoint(x: position.x + tileSize.width, y: position.y - tileSize.height),
            CGPoint(x: position.x, y: position.y - tileSize.height),
            CGPoint(x: position.x - tileSize.width, y: position.y - tileSize.height),
            CGPoint(x: position.x - tileSize.width, y: position.y),
            CGPoint(x: position.x - tileSize.width, y: position.y + tileSize.height),
        ]
        for pos in positions {
            let orb = SKSpriteNode(imageNamed: "orb0")
            orb.size = tileSize
            orb.texture?.filteringMode = .nearest
            orb.zPosition = GameConfiguration.sceneConfiguration.hudZPosition
            orb.position = position
            scene.addChildSafely(orb)
            
            let scale = SKAction.scaleUpAndDown(from: 0.1,
                                                with: 0.05,
                                                to: 1,
                                                with: 0.05,
                                                during: 0,
                                                repeating: 10)
            let fade = SKAction.fadeOut(withDuration: 0.5)
            let move = SKAction.move(to: pos, duration: 0.5)
            let groupAnimation = SKAction.group([scale, fade, move])
            
            let sequenceAnimation = SKAction.sequence([
                groupAnimation,
                SKAction.removeFromParent()
            ])
            
            orb.run(sequenceAnimation)
        }
    }
}

// MARK: - State ID animations

public extension GameAnimation {
    
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
