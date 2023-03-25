//
//  Player.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 01/02/23.
//

import SpriteKit
import PlayfulKit

public class Dice {
    
    public var orientation: Orientation = .right
    public var node: PKObjectNode = PKObjectNode()
    
    public enum Roll: Int, CaseIterable {
        case one = 1
        case two = 2
        case three = 3
        case four = 4
        case five = 5
        case six = 6
    }
    public enum Orientation {
        case right
        case left
        case up
        case down
    }
    public enum DiceAction {
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
                return GameConfiguration.imageConfigurationKey.rightArrow
            case .moveLeft:
                return GameConfiguration.imageConfigurationKey.leftArrow
            case .moveUp:
                return GameConfiguration.imageConfigurationKey.upArrow
            case .moveDown:
                return GameConfiguration.imageConfigurationKey.downArrow
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
    public enum DiceState {
        case normal
        case inAction
    }
    
    public var state: DiceState = .normal
    public var currentRoll: Roll = .one
    public var range: CGFloat = GameConfiguration.playerConfiguration.range
    public var attackSpeed: CGFloat = GameConfiguration.playerConfiguration.attackSpeed
    public var logic: GameObjectLogic = GameObjectLogic(health: 5, damage: 1, isDestructible: true, isIntangible: false)
    
    public var isProjectileTurningBack: Bool = false
    public var isJumping: Bool = false
    public var canAct: Bool = true
    public var isDead: Bool = false
    
    public var interactionStatus: PlayerInteractionStatus = .none
    public var actions: [DiceAction] = []

    public var bag: [GameItem] = []
}

extension Dice {
    
    var rightRunFrames: [String]? {
        let currentRollValue = currentRoll.rawValue
        let animation = GameSpriteAnimation.get(GameConfiguration.playerConfiguration.runRightAnimation)
        let frames = animation?.frames.compactMap {
            $0.replacingOccurrences(of: "#", with: "\(currentRollValue)")
        }
        return frames
    }
    var leftRunFrames: [String]? {
        let currentRollValue = currentRoll.rawValue
        let animation = GameSpriteAnimation.get(GameConfiguration.playerConfiguration.runLeftAnimation)
        let frames = animation?.frames.compactMap {
            $0.replacingOccurrences(of: "#", with: "\(currentRollValue)")
        }
        return frames
    }
    
    var runDuration: Double {
        guard let framesCount = rightRunFrames?.count else { return 0 }
        let duration = Double(framesCount) * GameConfiguration.playerConfiguration.runTimePerFrame
        return duration
    }
    
    func run() {
        guard let rightRunFrames = rightRunFrames else { return }
        guard let leftRunFrames = leftRunFrames else { return }
        let frames = orientation == .right ? rightRunFrames : leftRunFrames
        let action = SKAction.animate(with: frames, filteringMode: .nearest, timePerFrame: GameConfiguration.playerConfiguration.runTimePerFrame)
        SKAction.start(actionOnLaunch: nil, animation: action, node: node, actionOnEnd: nil)
    }
    
    func advanceRoll() {
        guard let lastRoll = Roll.allCases.last?.rawValue else { return }
        if currentRoll.rawValue < lastRoll {
            currentRoll.next()
            print("Advance")
        } else {
            currentRoll = .one
        }
    }
}
