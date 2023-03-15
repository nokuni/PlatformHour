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
        
        var arrow: String {
            switch self {
            case .right:
                return GameApp.imageConfigurationKey.rightArrow
            case .left:
                return GameApp.imageConfigurationKey.leftArrow
            case .up:
                return GameApp.imageConfigurationKey.upArrow
            case .down:
                return GameApp.imageConfigurationKey.downArrow
            }
        }
    }
    
    public var currentRoll: Roll = .one
    public var range: CGFloat = GameApp.playerConfiguration.range
    public var attackSpeed: CGFloat = GameApp.playerConfiguration.attackSpeed
    
    public var interactionStatus: PlayerInteractionStatus = .none
    public var bag: [GameItem] = []
}

extension Dice {
    
    var rightRunFrames: [String]? {
        let currentRollValue = currentRoll.rawValue
        let animation = GameSpriteAnimation.get(GameApp.playerConfiguration.runRightAnimation)
        let frames = animation?.frames.compactMap {
            $0.replacingOccurrences(of: "#", with: "\(currentRollValue)")
        }
        return frames
    }
    var leftRunFrames: [String]? {
        let currentRollValue = currentRoll.rawValue
        let animation = GameSpriteAnimation.get(GameApp.playerConfiguration.runLeftAnimation)
        let frames = animation?.frames.compactMap {
            $0.replacingOccurrences(of: "#", with: "\(currentRollValue)")
        }
        return frames
    }
    var runDuration: Double {
        guard let framesCount = rightRunFrames?.count else { return 0 }
        let duration = Double(framesCount) * GameApp.playerConfiguration.runTimePerFrame
        return duration
    }
    
    func run() {
        guard let rightRunFrames = rightRunFrames else { return }
        guard let leftRunFrames = leftRunFrames else { return }
        let frames = orientation == .right ? rightRunFrames : leftRunFrames
        let action = SKAction.animate(with: frames, filteringMode: .nearest, timePerFrame: GameApp.playerConfiguration.runTimePerFrame)
        SKAction.start(actionOnLaunch: nil, animation: action, node: node) {
            self.advanceRoll()
        }
    }
    
    func advanceRoll() {
        guard let lastRoll = Roll.allCases.last?.rawValue else { return }
        if currentRoll.rawValue < lastRoll {
            currentRoll.next()
        } else {
            currentRoll = .one
        }
    }
}
