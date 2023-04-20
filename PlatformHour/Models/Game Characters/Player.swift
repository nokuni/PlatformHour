//
//  Player.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 01/02/23.
//

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
    var energy = 100
    var maxEnergy = 100
    
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
    
    func refillEnergy() {
        guard energy < maxEnergy else { return }
        energy = maxEnergy
    }
    
    func consumeEnergy(amount: Int) {
        guard energy > 0 else { return }
        guard (energy - amount) >= 0 else { return }
        energy -= amount
    }
}

// MARK: - Sprites

extension Player {
    
    /// Returns the current sprite image of the dice.
    var sprite: String? {
        let currentRollValue = currentRoll.rawValue
        return object?.image.replacingOccurrences(of: "#", with: "\(currentRollValue)")
    }
    
    var energyFrames: [String] {
        var image = ""
        
        switch true {
        case energy == maxEnergy:
            image = "energyCharged5"
        case energy >= 80:
            image = "energyCharged4"
        case energy >= 50:
            image = "energyCharged3"
        case energy >= 20:
            image = "energyCharged2"
        case energy > 0:
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
    
    func updateBarrierOnRun() {
        guard let barrier = node.childNode(withName: "Barrier") as? SKSpriteNode else { return }
        let frames = orientation == .right ? ["barrierRunRight", "barrierRunMid", "barrierRunLeft", "barrierIdle", "barrierRunRight", "barrierRunMid", "barrierRunLeft", "barrierIdle"] : ["barrierRunLeft", "barrierRunMid", "barrierRunRight", "barrierIdle", "barrierRunLeft", "barrierRunMid", "barrierRunRight", "barrierIdle"]
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
    
    /// Play the hit action animation.
    func hitted(scene: GameScene, by enemy: PKObjectNode, completion: (() -> Void)?) {
        guard let hitFrames = frames(stateID: .hit) else { return }
        let hitAnimation = SKAction.animate(with: hitFrames, filteringMode: .nearest, timePerFrame: GameConfiguration.playerConfiguration.hitTimePerFrame)
        let knockBackAnimation = knockedBack(by: enemy)
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
