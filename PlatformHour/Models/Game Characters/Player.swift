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
    
    var orientation: Orientation = .right
    var currentRoll: Roll = .one
    var interactionStatus: PlayerInteractionStatus = .none
    
    var node = PKObjectNode()
    var object = GameObject.player
    var state = PlayerState()
    var stats = Stats(range: GameConfiguration.playerConfiguration.range,
                      attackSpeed: GameConfiguration.playerConfiguration.attackSpeed)
    
    var actions: [SequenceAction] = []
    var bag: [GameObject] = []
    var energy: Int = 0
    
    enum Power: String {
        case movement = "Movement"
        case levitate = "Levitate"
    }
    
    enum Roll: Int, CaseIterable {
        case one = 1
        case two = 2
        case three = 3
        case four = 4
        case five = 5
        case six = 6
    }
    
    enum Orientation {
        case right
        case left
        case up
        case down
    }
    
    enum SequenceAction {
        case none
        case moveRight
        case moveLeft
        case moveUp
        case moveDown
        
        var icon: String {
            switch self {
            case .none:
                return ""
            case .moveRight:
                return GameConfiguration.imageKey.rightArrow
            case .moveLeft:
                return GameConfiguration.imageKey.leftArrow
            case .moveUp:
                return GameConfiguration.imageKey.upArrow
            case .moveDown:
                return GameConfiguration.imageKey.downArrow
            }
        }
        
        var value: (x: Int, y: Int) {
            switch self {
            case .none:
                return (x: 0, y: 0)
            case .moveRight:
                return (x: 0, y: 1)
            case .moveLeft:
                return (x: 0, y: -1)
            case .moveUp:
                return (x: -1, y: 0)
            case .moveDown:
                return (x: 1, y: 0)
            }
        }
    }
    
    var isAnimating: Bool { node.hasActions() }
}

// MARK: - Health/Energy

extension Player {
    
    /// Returns the current health of the player.
    var currentHealth: Int {
        guard let logic = object?.logic else { return 0 }
        let health = logic.health - node.logic.healthLost
        return health
    }
    
    /// Returns the current bar health of the player.
    var currentBarHealth: CGFloat {
        guard let logic = object?.logic else { return 0 }
        let health = CGFloat(currentHealth) / CGFloat(logic.health)
        return health
    }
    
    /// Returns max energy of the player.
    func maxEnergy(game: Game) -> Int {
        guard let maxEnergySave = game.currentSave?.maxEnergy else { return 100 }
        let maxEnergy = Int(maxEnergySave)
        return maxEnergy
    }
    
    /// Refills current energy by a specific amount.
    func refillEnergy(amount: Int, game: Game) {
        let maxEnergy = maxEnergy(game: game)
        guard energy < maxEnergy else { return }
        energy += amount
    }
    
    /// Refills all energy.
    func refillTotalEnergy(game: Game) {
        let maxEnergy = maxEnergy(game: game)
        energy = maxEnergy
    }
    
    /// Increases max energy by a specific amount.
    func increaseMaxEnergy(game: Game, amount: Int) {
        game.currentSave?.maxEnergy += Int32(amount)
        game.updateSaves()
        refillTotalEnergy(game: game)
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

// MARK: - Logic

extension Player {
    
    /// Check if the player has his barrier.
    func hasBarrier(scene: GameScene) -> Bool {
        guard let passedConversations = scene.game?.currentSave?.passedConversations else { return false }
        return passedConversations.contains("Energy Power Up Conversation")
    }
    
    /// Unlock a new power for the player depending on his max energy.
    func unlockPower(game: Game) {
        let maxEnergy = maxEnergy(game: game)
        
        switch true {
        case maxEnergy == 125:
            game.currentSave?.powers?.append(Power.levitate.rawValue)
        default:
            print("No power unlocked")
        }
        
        game.updateSaves()
    }
    
    /// Check if the player has unlocked a power.
    func hasPlayerUnlock(game: Game, power: Power) -> Bool {
        guard let powers = game.currentSave?.powers else { return false }
        return powers.contains(power.rawValue)
    }
}

// MARK: - Sprites

extension Player {
    
    /// Returns the current sprite image of the dice.
    var sprite: String? {
        let currentRollValue = currentRoll.rawValue
        return object?.image.replacingOccurrences(of: "#", with: "\(currentRollValue)")
    }
    
    /// Returns the image frames of the energy HUD.
    func energyFrames(game: Game) -> [String] {
        var image = ""
        let maxEnergy = maxEnergy(game: game)
        
        switch true {
        case energy > maxEnergy.percentageValue(percentage: 90):
            image = "energyCharged5"
        case energy > maxEnergy.percentageValue(percentage: 70):
            image = "energyCharged4"
        case energy > maxEnergy.percentageValue(percentage: 50):
            image = "energyCharged3"
        case energy > maxEnergy.percentageValue(percentage: 30):
            image = "energyCharged2"
        case energy > maxEnergy.percentageValue(percentage: 10):
            image = "energyCharged1"
        default:
            image = "energyCharged0"
        }
        
        return ["\(image)0", "\(image)1", "\(image)2", "\(image)3"]
    }
    
    /// Returns the animation frame images of an stateID animation.
    func frames(stateID: GameAnimation.StateID) -> [String]? {
        let currentRollValue = currentRoll.rawValue
        let animation = object?.animations.first(where: { $0.identifier == stateID.rawValue })
        let frames = animation?.frames.replacingOccurences(character: "#", newCharacter: "\(currentRollValue)")
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
    
    /// Play the hit action animation.
    func knockBackHitted(scene: GameScene,
                         by enemy: PKObjectNode,
                         canChooseDirection: Bool = true,
                         onRight: Bool = true,
                         completion: (() -> Void)? = nil) {
        let knockBackAnimation =
        canChooseDirection ?
        knockedBack(by: enemy, onRight: onRight) :
        knockedBack(by: enemy)
        let groupedAnimation = SKAction.group([hitAnimation, knockBackAnimation])
        node.removeAllActions()
        SKAction.animate(action: groupedAnimation, node: node) {
            completion?()
        }
    }
    
    /// Advance the current roll of the dice.
    func rollUp() {
        guard let lastRoll = Roll.allCases.last?.rawValue else { return }
        if currentRoll.rawValue < lastRoll {
            currentRoll = currentRoll.next()
        } else {
            currentRoll = .one
        }
    }
    
    /// Advance the current roll of the dice.
    func rollDown() {
        guard let firstRoll = Roll.allCases.first?.rawValue else { return }
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
