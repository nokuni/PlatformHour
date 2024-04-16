//
//  Player.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 01/02/23.
//

import SwiftUI
import SpriteKit
import PlayfulKit

final class Player {
    
    var orientation: PlayerOrientation = .right
    var currentRoll: PlayerRoll = .one
    var interactionStatus: PlayerInteractionStatus = .none
    
    var node = PKObjectNode()
    var state = PlayerState()
    var stats = Stats(range: GameConfiguration.playerConfiguration.range,
                      attackSpeed: GameConfiguration.playerConfiguration.attackSpeed)
    
    var actions: [PlayerSequenceAction] = []
    var bag: [GameObject] = []
    var energy: Int = 0
    var maxEnergy: Int = 0
    
    var object: GameObject? { GameObject.player }
    var isAnimating: Bool { node.hasActions() }
}

// MARK: - Health/Energy

extension Player {
    
    /// Returns the current health of the player.
    var currentHealth: Int {
        return 10
        guard let logic = object?.logic else { return 0 }
//        let health = logic.health - node.logic.healthLost
//        return health
    }
    
    /// Returns the current bar health of the player.
    var currentBarHealth: CGFloat {
        guard let logic = object?.logic else { return 0 }
        let health = CGFloat(currentHealth) / CGFloat(logic.health)
        return health
    }
    
    /// Refills current energy by a specific amount.
    func refillEnergy(amount: Int) {
        guard energy < maxEnergy else { return }
        energy += amount
    }
    
    /// Refills all energy.
    func refillTotalEnergy() {
        energy = maxEnergy
    }
    
    /// Consumes current energy by a specific amount.
    func consumeEnergy(amount: Int) {
        guard energy > 0 else { return }
        if (energy - amount) <= 0 { energy = 0 } else { energy -= amount }
    }
    
    /// Check if current energy is zero or less.
    var isOutOfEnergy: Bool {
        energy <= 0
    }
}

// MARK: - Sprites

extension Player {
    
    /// Returns the current sprite image of the dice.
    var sprite: String? {
        let currentRollValue = currentRoll.rawValue
        return object?.image.replacingOccurrences(of: "#", with: "\(currentRollValue)")
    }
    
    /// Returns the animation frame images of an stateID animation.
    func frames(stateID: GameAnimation.StateID) -> [String]? {
        let currentRollValue = currentRoll.rawValue
        let animation = object?.animations.first(where: { $0.identifier == stateID.rawValue })
        let frames = animation?.frames.map {
            $0.replacingOccurrences(of: "#", with: "\(currentRollValue)")
        }
//        let frames = animation?.frames.replaceMultipleOccurrences(character: "#", newCharacter: "\(currentRollValue)")
        return frames
    }
}

// MARK: - Animations

extension Player {
    
    /// Returns the player run duration.
    var runDuration: Double {
        let rightRunFrames = frames(stateID: .runRight)
        guard let framesCount = rightRunFrames?.count else { return 0 }
        let duration = Double(framesCount) * GameConfiguration.playerConfiguration.runTimePerFrame
        return duration
    }
    
    /// Returns a knockback animation.
    private func knockedBack(by enemy: PKObjectNode) -> SKAction {
        let tileSize = GameConfiguration.sceneConfiguration.tileSize
        let knockBack = enemy.xScale > 0 ?
        SKAction.move(to: CGPoint(x: node.position.x + (tileSize.width * 2), y: node.position.y), duration: 0.1) :
        SKAction.move(to: CGPoint(x: node.position.x - (tileSize.width * 2), y: node.position.y), duration: 0.1)
        return knockBack
    }
    
    /// Returns a knockback animation.
    private func knockedBack(by enemy: PKObjectNode, onRight: Bool = true) -> SKAction {
        let tileSize = GameConfiguration.sceneConfiguration.tileSize
        let knockBack = onRight ?
        SKAction.move(to: CGPoint(x: node.position.x + (tileSize.width * 2), y: node.position.y), duration: 0.1) :
        SKAction.move(to: CGPoint(x: node.position.x - (tileSize.width * 2), y: node.position.y), duration: 0.1)
        return knockBack
    }
}

// MARK: - Actions

extension Player {
    
    /// Play the run action animation.
    func run() {
        guard let rightRunFrames = frames(stateID: .runRight) else { return }
        guard let leftRunFrames = frames(stateID: .runLeft) else { return }
        let frames = orientation == .right ? rightRunFrames : leftRunFrames
        let action = SKAction.animate(with: frames, filteringMode: .nearest, timePerFrame: GameConfiguration.playerConfiguration.runTimePerFrame)
        SKAction.animate(action: action, node: node, endCompletion: nil)
        updateBarrierOnRun()
    }
    
    /// Update the barrier sprite on run
    func updateBarrierOnRun() {
        guard let barrier = node.childNode(withName: "Barrier") as? SKSpriteNode else { return }
        guard let barrierRunRightFrames = frames(stateID: .barrierRight) else { return }
        guard let barrierRunLeftFrames = frames(stateID: .barrierLeft) else { return }
        let frames = orientation == .right ? barrierRunRightFrames : barrierRunLeftFrames
        let animation = SKAction.animate(with: frames, filteringMode: .nearest, timePerFrame: GameConfiguration.playerConfiguration.runTimePerFrame)
        barrier.run(animation)
    }
    
    /// Play the death action animation.
    func death(scene: GameScene) {
        guard let deathFrames = frames(stateID: .death) else { return }
        let animationNode = SKSpriteNode()
        animationNode.size = GameConfiguration.sceneConfiguration.tileSize
        animationNode.zPosition = GameConfiguration.sceneConfiguration.objectZPosition
        animationNode.position = node.position
        scene.addChildSafely(animationNode)
        
        let animation = SKAction.animate(with: deathFrames, filteringMode: .nearest, timePerFrame: GameConfiguration.playerConfiguration.deathTimePerFrame)
        
        let sequence = SKAction.sequence([
            animation,
            SKAction.fadeOutAndIn(fadeOutDuration: 0.05, fadeInDuration: 0.05, repeating: 5),
            SKAction.removeFromParent()
        ])
        
        SKAction.animate(startCompletion: node.removeFromParent,
                         action: sequence,
                         node: animationNode)
    }
    
    /// Hitted animation.
    var hitAnimation: SKAction {
        guard let hitFrames = frames(stateID: .hit) else { return SKAction.empty() }
        let hitAnimation = SKAction.animate(with: hitFrames, filteringMode: .nearest, timePerFrame: GameConfiguration.playerConfiguration.hitTimePerFrame)
        return hitAnimation
    }
    
    /// Play the hitted animation.
    func blinkHit() {
        guard let barrier = node.childNode(withName: "Barrier") as? SKSpriteNode else { return }
        var toggle: Bool = true
        let configuration = PKTimerNode.TimerConfiguration(countdown: 10, counter: 1, timeInterval: 0.05, actionOnGoing: {
            if toggle {
                barrier.color = .red
                toggle.toggle()
            } else {
                barrier.color = UIColor(Color.spiritBlue)
                toggle.toggle()
            }
        })
        let timerNode = PKTimerNode(configuration: configuration)
        barrier.addChildSafely(timerNode)
        timerNode.start()
    }
    
    func hit() {
        node.run(hitAnimation)
    }
    
    /// Advance the current roll of the dice.
    func rollUp() {
        guard let lastRoll = PlayerRoll.allCases.last?.rawValue else { return }
        if currentRoll.rawValue < lastRoll {
            currentRoll = currentRoll.next()
        } else {
            currentRoll = .one
        }
    }
    
    /// Advance the current roll of the dice.
    func rollDown() {
        guard let firstRoll = PlayerRoll.allCases.first?.rawValue else { return }
        if currentRoll.rawValue > firstRoll {
            currentRoll = currentRoll.previous()
        } else {
            currentRoll = .one
        }
    }
    
    func updateDiceSprite() {
        node.texture = SKTexture(imageNamed: "player\(currentRoll.rawValue)Idle")
        node.texture?.filteringMode = .nearest
    }
}
